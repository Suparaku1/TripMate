-- TripMate AI Database Initialization Script
-- This script sets up the initial schema for the travel planner application

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create travel_agents table
CREATE TABLE IF NOT EXISTS travel_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_type VARCHAR(50) NOT NULL,
    description TEXT,
    capabilities TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create travel_plans table
CREATE TABLE IF NOT EXISTS travel_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id VARCHAR(255) NOT NULL UNIQUE,
    user_input TEXT NOT NULL,
    destination VARCHAR(255),
    start_date DATE,
    end_date DATE,
    budget_usd NUMERIC(10, 2),
    travelers_count INT DEFAULT 1,
    status VARCHAR(50) DEFAULT 'planning',
    itinerary JSONB,
    flight_results JSONB,
    hotel_results JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create travel_recommendations table
CREATE TABLE IF NOT EXISTS travel_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES travel_plans(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50),
    content JSONB NOT NULL,
    source VARCHAR(100),
    relevance_score NUMERIC(3, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create flight_records table
CREATE TABLE IF NOT EXISTS flight_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES travel_plans(id) ON DELETE CASCADE,
    departure_city VARCHAR(100),
    arrival_city VARCHAR(100),
    departure_date DATE,
    arrival_date DATE,
    airline VARCHAR(100),
    price_usd NUMERIC(10, 2),
    booking_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create hotel_records table
CREATE TABLE IF NOT EXISTS hotel_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES travel_plans(id) ON DELETE CASCADE,
    hotel_name VARCHAR(255),
    city VARCHAR(100),
    checkin_date DATE,
    checkout_date DATE,
    price_per_night_usd NUMERIC(10, 2),
    total_nights INT,
    total_price_usd NUMERIC(10, 2),
    booking_url VARCHAR(500),
    rating NUMERIC(3, 1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_travel_plans_thread_id ON travel_plans(thread_id);
CREATE INDEX idx_travel_plans_destination ON travel_plans(destination);
CREATE INDEX idx_travel_plans_created_at ON travel_plans(created_at DESC);
CREATE INDEX idx_flight_records_plan_id ON flight_records(plan_id);
CREATE INDEX idx_hotel_records_plan_id ON hotel_records(plan_id);
CREATE INDEX idx_travel_recommendations_plan_id ON travel_recommendations(plan_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_travel_plans_timestamp BEFORE UPDATE ON travel_plans
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_travel_agents_timestamp BEFORE UPDATE ON travel_agents
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Insert default travel agents
INSERT INTO travel_agents (agent_type, description, capabilities) VALUES
('flight_searcher', 'Searches and books flights', ARRAY['search_flights', 'compare_prices', 'book_flight']),
('hotel_finder', 'Finds and books accommodations', ARRAY['search_hotels', 'filter_amenities', 'check_reviews']),
('itinerary_planner', 'Plans daily itineraries', ARRAY['create_schedule', 'add_activities', 'estimate_times']),
('travel_advisor', 'Provides travel advice', ARRAY['safety_info', 'visa_requirements', 'local_customs'])
ON CONFLICT DO NOTHING;

-- Set permissions
ALTER TABLE travel_plans OWNER TO tripmate_user;
ALTER TABLE travel_recommendations OWNER TO tripmate_user;
ALTER TABLE flight_records OWNER TO tripmate_user;
ALTER TABLE hotel_records OWNER TO tripmate_user;
ALTER TABLE travel_agents OWNER TO tripmate_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tripmate_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tripmate_user;
