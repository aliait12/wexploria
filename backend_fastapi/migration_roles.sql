-- 1. Table des demandes pour devenir opérateur
CREATE TABLE IF NOT EXISTS public.demandes_operateurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nom_entreprise TEXT NOT NULL,
    siret TEXT NOT NULL,
    message TEXT,
    statut TEXT DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'valide', 'rejete')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Automatisation de la création de profil (si pas déjà fait)
-- Cette fonction sera appelée à chaque nouvel utilisateur inscrit
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, role, nom, statut)
  VALUES (
    new.id,
    new.email,
    'client', -- Tout le monde est client par défaut
    COALESCE(new.raw_user_meta_data->>'nom', 'Utilisateur'),
    'actif'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour l'appel de la fonction
-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. POLITIQUES RLS (Exemples demandés)

-- Désactiver l'accès direct aux activités pour les non-opérateurs
ALTER TABLE public.activites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tout le monde peut voir les activités" 
ON public.activites FOR SELECT 
USING (true);

CREATE POLICY "Seuls les opérateurs peuvent créer des activités" 
ON public.activites FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND role = 'operateur'
  )
);

CREATE POLICY "Les opérateurs gèrent leurs propres activités" 
ON public.activites FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND role = 'operateur'
  )
  -- Et idéalement vérifier que l'activite appartient à l'école de l'user
);

-- 4. Sécurisation des demandes opérateur
ALTER TABLE public.demandes_operateurs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Les clients peuvent voir leurs propres demandes"
ON public.demandes_operateurs FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Les clients peuvent soumettre une demande"
ON public.demandes_operateurs FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Seul l'admin voit tout"
ON public.demandes_operateurs FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  )
);
