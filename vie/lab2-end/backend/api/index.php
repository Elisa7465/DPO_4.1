<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit();
}

$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$path_parts = explode('/', trim($path, '/'));

// Убираем 'api' и 'cv' из пути
$api_index = array_search('api', $path_parts);
if ($api_index !== false) {
    $path_parts = array_slice($path_parts, $api_index + 1);
}

$method = $_SERVER['REQUEST_METHOD'];

// Маршрутизация
if ($method === 'GET' && count($path_parts) === 1 && $path_parts[0] === 'cv') {
    // GET /api/cv - список всех резюме
    getResumes($db);
} elseif ($method === 'GET' && count($path_parts) === 2 && $path_parts[0] === 'cv' && is_numeric($path_parts[1])) {
    // GET /api/cv/{id} - получить резюме по id
    getResumeById($db, intval($path_parts[1]));
} elseif ($method === 'POST' && count($path_parts) === 3 && $path_parts[0] === 'cv' && $path_parts[2] === 'add') {
    // POST /api/cv/{id}/add - добавить новое резюме (id игнорируется)
    addResume($db);
} elseif ($method === 'POST' && count($path_parts) === 3 && $path_parts[0] === 'cv' && is_numeric($path_parts[1]) && $path_parts[2] === 'edit') {
    // POST /api/cv/{id}/edit - редактировать резюме
    editResume($db, intval($path_parts[1]));
} elseif ($method === 'POST' && count($path_parts) === 4 && $path_parts[0] === 'cv' && is_numeric($path_parts[1]) && $path_parts[2] === 'status' && $path_parts[3] === 'update') {
    // POST /api/cv/{id}/status/update - обновить статус
    updateStatus($db, intval($path_parts[1]));
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Not found']);
}

function getResumes($db) {
    try {
        $query = "SELECT r.*, 
                  COALESCE(json_agg(
                      json_build_object(
                          'id', e.id,
                          'institution', e.institution,
                          'faculty', e.faculty,
                          'specialization', e.specialization,
                          'graduationYear', e.graduation_year
                      )
                  ) FILTER (WHERE e.id IS NOT NULL), '[]') as educations
                  FROM resumes r
                  LEFT JOIN educations e ON r.id = e.resume_id
                  GROUP BY r.id
                  ORDER BY r.created_at DESC";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $resumes = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $row['educations'] = json_decode($row['educations'], true);
            $resumes[] = formatResume($row);
        }
        
        echo json_encode($resumes, JSON_UNESCAPED_UNICODE);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
}

function getResumeById($db, $id) {
    try {
        $query = "SELECT r.*, 
                  COALESCE(json_agg(
                      json_build_object(
                          'id', e.id,
                          'institution', e.institution,
                          'faculty', e.faculty,
                          'specialization', e.specialization,
                          'graduationYear', e.graduation_year
                      )
                  ) FILTER (WHERE e.id IS NOT NULL), '[]') as educations
                  FROM resumes r
                  LEFT JOIN educations e ON r.id = e.resume_id
                  WHERE r.id = :id
                  GROUP BY r.id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Resume not found'], JSON_UNESCAPED_UNICODE);
            return;
        }
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $row['educations'] = json_decode($row['educations'], true);
        echo json_encode(formatResume($row), JSON_UNESCAPED_UNICODE);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
}

function addResume($db) {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $db->beginTransaction();
        
        // Вставка резюме
        $query = "INSERT INTO resumes (profession, city, photo_url, full_name, phone, email, birth_date, status, education_level, desired_salary, skills, about)
                  VALUES (:profession, :city, :photo_url, :full_name, :phone, :email, :birth_date, :status, :education_level, :desired_salary, :skills, :about)
                  RETURNING id";
        
        $stmt = $db->prepare($query);
        $stmt->execute([
            ':profession' => $data['profession'] ?? '',
            ':city' => $data['city'] ?? '',
            ':photo_url' => $data['photoUrl'] ?? '',
            ':full_name' => $data['fullName'] ?? '',
            ':phone' => $data['phone'] ?? '',
            ':email' => $data['email'] ?? '',
            ':birth_date' => $data['birthDate'] ?? null,
            ':status' => $data['status'] ?? 'Новый',
            ':education_level' => $data['educationLevel'] ?? '',
            ':desired_salary' => $data['desiredSalary'] ?? '',
            ':skills' => $data['skills'] ?? '',
            ':about' => $data['about'] ?? ''
        ]);
        
        $resume_id = $db->lastInsertId();
        
        // Вставка образований
        if (!empty($data['educations']) && is_array($data['educations'])) {
            $edu_query = "INSERT INTO educations (resume_id, institution, faculty, specialization, graduation_year)
                          VALUES (:resume_id, :institution, :faculty, :specialization, :graduation_year)";
            $edu_stmt = $db->prepare($edu_query);
            
            foreach ($data['educations'] as $edu) {
                if (!empty($edu['institution']) || !empty($edu['faculty']) || 
                    !empty($edu['specialization']) || !empty($edu['graduationYear'])) {
                    $edu_stmt->execute([
                        ':resume_id' => $resume_id,
                        ':institution' => $edu['institution'] ?? '',
                        ':faculty' => $edu['faculty'] ?? '',
                        ':specialization' => $edu['specialization'] ?? '',
                        ':graduation_year' => !empty($edu['graduationYear']) ? intval($edu['graduationYear']) : null
                    ]);
                }
            }
        }
        
        $db->commit();
        
        http_response_code(201);
        echo json_encode(['id' => $resume_id, 'message' => 'Resume created successfully'], JSON_UNESCAPED_UNICODE);
    } catch (PDOException $e) {
        $db->rollBack();
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
}

function editResume($db, $id) {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $db->beginTransaction();
        
        // Проверка существования резюме
        $check_query = "SELECT id FROM resumes WHERE id = :id";
        $check_stmt = $db->prepare($check_query);
        $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $check_stmt->execute();
        
        if ($check_stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Resume not found'], JSON_UNESCAPED_UNICODE);
            return;
        }
        
        // Обновление резюме
        $query = "UPDATE resumes SET 
                  profession = :profession,
                  city = :city,
                  photo_url = :photo_url,
                  full_name = :full_name,
                  phone = :phone,
                  email = :email,
                  birth_date = :birth_date,
                  status = :status,
                  education_level = :education_level,
                  desired_salary = :desired_salary,
                  skills = :skills,
                  about = :about
                  WHERE id = :id";
        
        $stmt = $db->prepare($query);
        $stmt->execute([
            ':id' => $id,
            ':profession' => $data['profession'] ?? '',
            ':city' => $data['city'] ?? '',
            ':photo_url' => $data['photoUrl'] ?? '',
            ':full_name' => $data['fullName'] ?? '',
            ':phone' => $data['phone'] ?? '',
            ':email' => $data['email'] ?? '',
            ':birth_date' => $data['birthDate'] ?? null,
            ':status' => $data['status'] ?? 'Новый',
            ':education_level' => $data['educationLevel'] ?? '',
            ':desired_salary' => $data['desiredSalary'] ?? '',
            ':skills' => $data['skills'] ?? '',
            ':about' => $data['about'] ?? ''
        ]);
        
        // Удаление старых образований
        $delete_edu_query = "DELETE FROM educations WHERE resume_id = :resume_id";
        $delete_edu_stmt = $db->prepare($delete_edu_query);
        $delete_edu_stmt->bindParam(':resume_id', $id, PDO::PARAM_INT);
        $delete_edu_stmt->execute();
        
        // Вставка новых образований
        if (!empty($data['educations']) && is_array($data['educations'])) {
            $edu_query = "INSERT INTO educations (resume_id, institution, faculty, specialization, graduation_year)
                          VALUES (:resume_id, :institution, :faculty, :specialization, :graduation_year)";
            $edu_stmt = $db->prepare($edu_query);
            
            foreach ($data['educations'] as $edu) {
                if (!empty($edu['institution']) || !empty($edu['faculty']) || 
                    !empty($edu['specialization']) || !empty($edu['graduationYear'])) {
                    $edu_stmt->execute([
                        ':resume_id' => $id,
                        ':institution' => $edu['institution'] ?? '',
                        ':faculty' => $edu['faculty'] ?? '',
                        ':specialization' => $edu['specialization'] ?? '',
                        ':graduation_year' => !empty($edu['graduationYear']) ? intval($edu['graduationYear']) : null
                    ]);
                }
            }
        }
        
        $db->commit();
        
        echo json_encode(['message' => 'Resume updated successfully'], JSON_UNESCAPED_UNICODE);
    } catch (PDOException $e) {
        $db->rollBack();
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
}

function updateStatus($db, $id) {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        $status = $data['status'] ?? null;
        
        if (!$status) {
            http_response_code(400);
            echo json_encode(['error' => 'Status is required'], JSON_UNESCAPED_UNICODE);
            return;
        }
        
        $query = "UPDATE resumes SET status = :status WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->execute([
            ':id' => $id,
            ':status' => $status
        ]);
        
        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Resume not found'], JSON_UNESCAPED_UNICODE);
            return;
        }
        
        echo json_encode(['message' => 'Status updated successfully'], JSON_UNESCAPED_UNICODE);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
}

function formatResume($row) {
    // Вычисление возраста
    $age = null;
    if (!empty($row['birth_date'])) {
        $birth_date = new DateTime($row['birth_date']);
        $today = new DateTime();
        $age = $today->diff($birth_date)->y;
    }
    
    return [
        'id' => intval($row['id']),
        'profession' => $row['profession'] ?? '',
        'city' => $row['city'] ?? '',
        'photoUrl' => $row['photo_url'] ?? '',
        'fullName' => $row['full_name'] ?? '',
        'phone' => $row['phone'] ?? '',
        'email' => $row['email'] ?? '',
        'birthDate' => $row['birth_date'] ?? '',
        'age' => $age,
        'status' => $row['status'] ?? 'Новый',
        'educationLevel' => $row['education_level'] ?? '',
        'educations' => $row['educations'] ?? [],
        'desiredSalary' => $row['desired_salary'] ?? '',
        'skills' => $row['skills'] ?? '',
        'about' => $row['about'] ?? '',
        'createdAt' => $row['created_at'] ?? '',
        'updatedAt' => $row['updated_at'] ?? ''
    ];
}
?>

