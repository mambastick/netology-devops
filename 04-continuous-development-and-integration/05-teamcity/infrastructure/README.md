# Infrastructure

Use the playbook from the original homework to prepare the Nexus host.

Before running the TeamCity build, update:

- `pom.xml`: replace `NEXUS_HOST` with the actual Nexus host.
- `teamcity/settings.xml`: provide `NEXUS_USERNAME` and `NEXUS_PASSWORD` in TeamCity agent environment or replace them with TeamCity parameters.
- `.teamcity/settings.kts`: replace `YOUR_GITHUB_LOGIN/YOUR_REPOSITORY` with the actual repository path, or let TeamCity overwrite this directory after enabling Versioned Settings.

