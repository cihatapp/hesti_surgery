-- =============================================
-- Storage Buckets for Hesti Surgery
-- =============================================

-- Patient Photos (max 10MB, JPEG/PNG)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'patient-photos',
  'patient-photos',
  false,
  10485760,  -- 10MB
  ARRAY['image/jpeg', 'image/png']
);

-- 3D Models (max 50MB, GLB/OBJ)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  '3d-models',
  '3d-models',
  false,
  52428800,  -- 50MB
  ARRAY['model/gltf-binary', 'application/octet-stream']
);

-- Reports (max 20MB, PDF)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'reports',
  'reports',
  false,
  20971520,  -- 20MB
  ARRAY['application/pdf']
);

-- =============================================
-- Storage RLS Policies
-- =============================================

-- Patient Photos policies
CREATE POLICY "Surgeons can upload patient photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'patient-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can view own patient photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'patient-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can delete own patient photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'patient-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- 3D Models policies
CREATE POLICY "Surgeons can upload 3d models"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = '3d-models'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can view own 3d models"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = '3d-models'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can delete own 3d models"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = '3d-models'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Reports policies
CREATE POLICY "Surgeons can upload reports"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can view own reports"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Surgeons can delete own reports"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
