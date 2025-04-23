-- Enable storage extension
CREATE EXTENSION IF NOT EXISTS "pgjwt";
CREATE EXTENSION IF NOT EXISTS "pg_net";
CREATE EXTENSION IF NOT EXISTS "pg_graphql";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create storage buckets if not exists
INSERT INTO storage.buckets (id, name, public) 
VALUES ('expense-receipts', 'expense-receipts', true)
ON CONFLICT (id) DO NOTHING;

-- Create RLS policies for expense-receipts bucket
CREATE POLICY "Anyone can read expense receipts"
ON storage.objects
FOR SELECT
USING (bucket_id = 'expense-receipts');

CREATE POLICY "Authenticated users can upload expense receipts"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'expense-receipts' AND (storage.foldername(name))[1] = 'receipts');

-- Updated policy to match the actual folder structure in the ExpenseService (receipts/expenseId/filename)
-- The policy allows users to delete if they own the expense with the expenseId
CREATE POLICY "Users can delete receipts for their expenses"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'expense-receipts' AND 
  (storage.foldername(name))[1] = 'receipts' AND
  EXISTS (
    SELECT 1 FROM expenses 
    WHERE id::text = (storage.foldername(name))[2] 
    AND employee_id = auth.uid()
  )
); 