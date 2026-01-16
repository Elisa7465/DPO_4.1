-- Создание таблицы резюме
CREATE TABLE IF NOT EXISTS resumes (
    id SERIAL PRIMARY KEY,
    profession VARCHAR(255),
    city VARCHAR(255),
    photo_url TEXT,
    full_name VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    birth_date DATE,
    status VARCHAR(50) DEFAULT 'Новый',
    education_level VARCHAR(100),
    desired_salary VARCHAR(100),
    skills TEXT,
    about TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание таблицы образований
CREATE TABLE IF NOT EXISTS educations (
    id SERIAL PRIMARY KEY,
    resume_id INTEGER REFERENCES resumes(id) ON DELETE CASCADE,
    institution VARCHAR(255),
    faculty VARCHAR(255),
    specialization VARCHAR(255),
    graduation_year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов
CREATE INDEX IF NOT EXISTS idx_resumes_status ON resumes(status);
CREATE INDEX IF NOT EXISTS idx_educations_resume_id ON educations(resume_id);

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER update_resumes_updated_at BEFORE UPDATE ON resumes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

