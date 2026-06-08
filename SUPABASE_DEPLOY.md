# Despliegue privado de GymLog

1. En Supabase, abre `SQL Editor` y ejecuta:

   `supabase/migrations/202605270001_gymlog_google_health.sql`

   Si la instalacion ya existia antes de separar Google Health y Drive, ejecuta
   tambien:

   `supabase/migrations/202605270002_split_google_health_drive_tokens.sql`

2. Confirma en `Edge Functions` > `Secrets` que existen:

   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - `GOOGLE_REDIRECT_URI=https://qserywqzvluqfrnyeggz.supabase.co/functions/v1/gymlog-google/callback`
   - `GYMLOG_APP_URL=https://ruizherrero1.github.io/Gym-app/`
   - `GYMLOG_OWNER_EMAIL`
   - `GYMLOG_DRIVE_PARENT_FOLDER_ID=14-senDPpZlJmyewiQk6WdTxbJlODlNtV`

3. En `Authentication` > `Email Templates` > `Magic Link`, configura el email
   para enviar un codigo OTP dentro de la PWA, por ejemplo:

   ```html
   <h2>Codigo de acceso a GymLog</h2>
   <p>Introduce este codigo en la app:</p>
   <p style="font-size:28px;font-weight:700;letter-spacing:4px">{{ .Token }}</p>
   ```

   De este modo el inicio de sesion funciona en la app instalada de iPhone sin
   abrir el enlace en Chrome o Safari. La app acepta el codigo numerico
   completo que configure/envie Supabase (por ejemplo, 6 u 8 digitos).

4. Crea una Edge Function llamada `gymlog-google` con el contenido de:

   `supabase/functions/gymlog-google/index.ts`

5. Esta funcion debe desplegarse permitiendo el callback OAuth sin JWT automatico.
   La propia funcion valida el JWT en todas las acciones privadas. La opcion
   ya esta declarada en `supabase/config.toml`.

   Con Supabase CLI:

   ```bash
   supabase functions deploy gymlog-google --no-verify-jwt --project-ref qserywqzvluqfrnyeggz
   ```

   Si la creas desde el editor del Dashboard, tras desplegar abre la pagina
   de detalle de `gymlog-google` y desactiva la opcion
   `Verify JWT with legacy secret`.

6. Prueba el boton `Conectar Google Health` desde GymLog antes de enviar el historial.
   La autorizacion de Google Health solicita solo scopes `googlehealth.*`.
   El token usado para el backup de Drive se conserva separado, ya que Google
   Health rechaza peticiones realizadas con un token que incluya scopes de Drive.

7. Verifica una sola sesion con `Sincronizar ultima sesion` antes de usar
   `Sincronizar historial`. Los entrenamientos anteriores al uso de Fitbit se
   registran sin frecuencia cardiaca y se muestran como tales en la app.

Para realizar primero la prueba local, añade tambien en Supabase
`Authentication` > `URL Configuration` > `Redirect URLs`:

```text
http://127.0.0.1:4173/**
```

Nota sobre Drive: si `drive.file` no permite crear inicialmente el JSON dentro
de la carpeta elegida, la funcion lo crea en Mi unidad. Muevelo una sola vez a
`Backups historial`; las actualizaciones siguientes conservan esa ubicacion.
