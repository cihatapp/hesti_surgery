-- =============================================
-- Hesti Surgery - Initial Database Schema
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. Surgeon Profiles (extends auth.users)
-- =============================================
CREATE TABLE public.surgeon_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  clinic_name TEXT,
  specialty TEXT DEFAULT 'rhinoplasty',
  license_number TEXT,
  phone TEXT,
  avatar_url TEXT,
  preferred_ai_model TEXT DEFAULT 'sam_3d_body',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.surgeon_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own profile"
  ON public.surgeon_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Surgeons can update own profile"
  ON public.surgeon_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Surgeons can insert own profile"
  ON public.surgeon_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- =============================================
-- 2. Patients
-- =============================================
CREATE TABLE public.patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  surgeon_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  phone TEXT,
  email TEXT,
  medical_notes TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_patients_surgeon_id ON public.patients(surgeon_id);
CREATE INDEX idx_patients_name ON public.patients(first_name, last_name);

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own patients"
  ON public.patients FOR SELECT
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can insert own patients"
  ON public.patients FOR INSERT
  WITH CHECK (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can update own patients"
  ON public.patients FOR UPDATE
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can delete own patients"
  ON public.patients FOR DELETE
  USING (auth.uid() = surgeon_id);

-- =============================================
-- 3. Surgery Cases
-- =============================================
CREATE TABLE public.surgery_cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  surgeon_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  surgery_type TEXT DEFAULT 'rhinoplasty',
  status TEXT NOT NULL DEFAULT 'planning'
    CHECK (status IN ('planning', 'scheduled', 'completed', 'archived')),
  scheduled_date TIMESTAMPTZ,
  completed_date TIMESTAMPTZ,
  surgeon_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_surgery_cases_surgeon_id ON public.surgery_cases(surgeon_id);
CREATE INDEX idx_surgery_cases_patient_id ON public.surgery_cases(patient_id);
CREATE INDEX idx_surgery_cases_status ON public.surgery_cases(status);

ALTER TABLE public.surgery_cases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own cases"
  ON public.surgery_cases FOR SELECT
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can insert own cases"
  ON public.surgery_cases FOR INSERT
  WITH CHECK (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can update own cases"
  ON public.surgery_cases FOR UPDATE
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can delete own cases"
  ON public.surgery_cases FOR DELETE
  USING (auth.uid() = surgeon_id);

-- =============================================
-- 4. Photos
-- =============================================
CREATE TABLE public.photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID NOT NULL REFERENCES public.surgery_cases(id) ON DELETE CASCADE,
  surgeon_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  angle TEXT NOT NULL
    CHECK (angle IN ('front', 'left_profile', 'right_profile', 'three_quarter_left', 'three_quarter_right', 'base')),
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  original_width INT,
  original_height INT,
  landmarks_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_photos_case_id ON public.photos(case_id);

ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own photos"
  ON public.photos FOR SELECT
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can insert own photos"
  ON public.photos FOR INSERT
  WITH CHECK (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can delete own photos"
  ON public.photos FOR DELETE
  USING (auth.uid() = surgeon_id);

-- =============================================
-- 5. 3D Models
-- =============================================
CREATE TABLE public.models_3d (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID NOT NULL REFERENCES public.surgery_cases(id) ON DELETE CASCADE,
  surgeon_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  model_type TEXT NOT NULL DEFAULT 'original'
    CHECK (model_type IN ('original', 'morphed', 'comparison')),
  storage_path TEXT NOT NULL,
  file_format TEXT DEFAULT 'glb' CHECK (file_format IN ('glb', 'obj')),
  file_size_bytes BIGINT,
  ai_model_used TEXT,
  ai_request_id TEXT,
  morph_parameters JSONB,
  parent_model_id UUID REFERENCES public.models_3d(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_models_3d_case_id ON public.models_3d(case_id);

ALTER TABLE public.models_3d ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own models"
  ON public.models_3d FOR SELECT
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can insert own models"
  ON public.models_3d FOR INSERT
  WITH CHECK (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can update own models"
  ON public.models_3d FOR UPDATE
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can delete own models"
  ON public.models_3d FOR DELETE
  USING (auth.uid() = surgeon_id);

-- =============================================
-- 6. Measurements
-- =============================================
CREATE TABLE public.measurements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID NOT NULL REFERENCES public.surgery_cases(id) ON DELETE CASCADE,
  surgeon_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  measurement_type TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  unit TEXT NOT NULL DEFAULT 'degrees',
  phase TEXT DEFAULT 'pre' CHECK (phase IN ('pre', 'post', 'planned')),
  landmarks_used JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_measurements_case_id ON public.measurements(case_id);

ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Surgeons can view own measurements"
  ON public.measurements FOR SELECT
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can insert own measurements"
  ON public.measurements FOR INSERT
  WITH CHECK (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can update own measurements"
  ON public.measurements FOR UPDATE
  USING (auth.uid() = surgeon_id);

CREATE POLICY "Surgeons can delete own measurements"
  ON public.measurements FOR DELETE
  USING (auth.uid() = surgeon_id);

-- =============================================
-- 7. Updated_at trigger function
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_surgeon_profiles
  BEFORE UPDATE ON public.surgeon_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_patients
  BEFORE UPDATE ON public.patients
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_surgery_cases
  BEFORE UPDATE ON public.surgery_cases
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================
-- 8. Auto-create surgeon profile on signup
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.surgeon_profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
