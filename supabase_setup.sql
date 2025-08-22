-- Create tasks table
CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  priority TEXT NOT NULL DEFAULT 'medium',
  location TEXT,
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  assigned_to UUID REFERENCES auth.users(id),
  tags TEXT[],
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Create RLS policies
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Policy for viewing tasks (admins see all, users see only assigned to them)
CREATE POLICY "Users can view their own tasks" ON public.tasks
  FOR SELECT USING (
    auth.uid() = user_id OR 
    auth.uid() = assigned_to OR
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
  );

-- Policy for inserting tasks (only admins)
CREATE POLICY "Only admins can create tasks" ON public.tasks
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
  );

-- Policy for updating tasks (admins can update any, users can update assigned to them)
CREATE POLICY "Users can update their own tasks" ON public.tasks
  FOR UPDATE USING (
    auth.uid() = assigned_to OR
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
  );

-- Policy for deleting tasks (only admins)
CREATE POLICY "Only admins can delete tasks" ON public.tasks
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
  );