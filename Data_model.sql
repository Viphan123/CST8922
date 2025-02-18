CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE ORG (
    org_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE NOT NULL,
    configuration JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE USERS (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    org_id UUID REFERENCES ORG(org_id) ON DELETE SET NULL
);

CREATE TABLE ROLE (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    permissions JSON NOT NULL
);

CREATE TABLE USER_ROLE (
    user_id UUID REFERENCES USERS(user_id) ON DELETE CASCADE,
    role_id UUID REFERENCES ROLE(role_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE DATA_SOURCE_CONFIG (
    source_config_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    configuration JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE DATA_SOURCE (
    source_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_config_id UUID REFERENCES DATA_SOURCE_CONFIG(source_config_id) ON DELETE SET NULL,
    org_id UUID REFERENCES ORG(org_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    external_id VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE URL (
    url_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    url TEXT UNIQUE NOT NULL,
    is_behind_wall BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CONTENT (
    content_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES DATA_SOURCE(source_id) ON DELETE CASCADE,
    external_id VARCHAR(255) UNIQUE NOT NULL,
    url_id UUID REFERENCES URL(url_id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    published_at TIMESTAMP,
    content TEXT NOT NULL,
    language VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PROMPT_CONFIG (
    prompt_config_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    system_message TEXT NOT NULL,
    temperature FLOAT NOT NULL,
    prompt_type VARCHAR(100) NOT NULL,
    org_id UUID REFERENCES ORG(org_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ANALYSIS_RESULT (
    analysis_result_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prompt_config_id UUID REFERENCES PROMPT_CONFIG(prompt_config_id) ON DELETE SET NULL,
    content_id UUID REFERENCES CONTENT(content_id) ON DELETE CASCADE,
    classification VARCHAR(255),
    misinformation BOOLEAN DEFAULT FALSE,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE KEYWORD (
    keyword_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    language VARCHAR(50) NOT NULL,
    org_id UUID REFERENCES ORG(org_id) ON DELETE CASCADE,
    keyword_classification JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE REPORT (
    report_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    org_id UUID REFERENCES ORG(org_id) ON DELETE CASCADE,
    configuration JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE INGESTION_LOG (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES DATA_SOURCE(source_id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    query_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    records_processed INTEGER NOT NULL
);

CREATE TABLE SCHEDULED_TASK (
    task_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    data_source_id UUID REFERENCES DATA_SOURCE(source_id) ON DELETE CASCADE,
    schedule VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AUDIT_LOG (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES USERS(user_id) ON DELETE SET NULL,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details JSON NOT NULL,
    ip_address VARCHAR(50)
);

CREATE TABLE FEEDBACK (
    feedback_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    analysis_result_id UUID REFERENCES ANALYSIS_RESULT(analysis_result_id) ON DELETE CASCADE,
    user_id UUID REFERENCES USERS(user_id) ON DELETE SET NULL,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
