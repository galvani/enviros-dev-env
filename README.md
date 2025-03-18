# Enviros IS - development environment

## Installation Instructions

Follow the steps below to set up the project:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/galvani/enviros-dev-env
   ```

2. **Initialize Submodules**
   ```bash
   git submodule update --init --recursive
   ```

3. **Set Up Environment Configuration**
    - Copy the default environment file:
      ```bash
      cp .env.dist .env
      ```
    - Open the `.env` file and adjust the settings to match your environment.

4. **Adjust Application Environment**
    - Navigate to the `app` directory:
      ```bash
      cd app
      ```
    - Set the `APP_ENV` variable in `.env` to match your environment (one of `test`, `dev`, or `prod`).
    - If you set `APP_ENV=dev`, adjust the `.env.dev` file to configure development-specific settings.


5. **Optional: Local Overrides**
    - To override any settings, create a `.env.local` file. This file will take precedence over others.


6. **Optional: Import database from SQL file**
> Pouzit prihlasovaci udaje z .env, ktery jste nakopirovali

   ```bash
   docker compose exec -iT mariadb mariadb -uenviros -penviros enviros < sql_file.sql`
   ```

7. **Install Dependencies**
   ```bash
   docker compose exec php composer install
   ```

8. **Install migrations**
`docker compose exec php vendor/bin/doctrine-migrations migr:migrate`

9. **Run Fixtures**
`docker compose exec php bin/fixtures.php`

## Container access 

If you wish to enter any container, use exec of docker composer.

### Database

   ```bash
   docker compose exec mariadb mariadb -uenviros -penviros enviros`
   ```

###  PHP

   ```bash
   docker compose exec php bash`
   ```
