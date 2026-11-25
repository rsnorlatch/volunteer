GRANT INSERT ON public.profiles TO anon;
GRANT SELECT ON public.activities TO authenticated;
GRANT INSERT ON public.activities TO authenticated;
GRANT UPDATE ON public.activities TO authenticated;
GRANT DELETE ON public.activities TO authenticated;

GRANT SELECT ON public.registrations TO authenticated;
GRANT INSERT ON public.registrations TO authenticated;
GRANT UPDATE on public.registrations TO authenticated;
GRANT DELETE ON public.registrations TO authenticated;