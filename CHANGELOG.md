
### 1.0.0
_Released 2015.10.14_

_Supported GH:E versions: GH:E 2.2+_

- Services use paths instead of subdomains
  - In the previous release, Waffle Takeout required tricky SSL certificate and DNS configuration to get all the services running correctly. Now, Waffle only requires a single SSL cert (or you can safely run with our self-signed cert), and does not require DNS configuration.
- Realtime updates for private repos
- Purposeful project creation
  - Previously, Waffle automatically created projects when you viewed a repo. This caused unexpected behavior, for users who did not intend to create a project. Now, Waffle prompts you to create a project when viewing a board for the first time.
- Ranking updates
  - Ranking cards while filtered caused unexpected results. These should be resolved.
- API
  - Waffle's API is still in private beta, but we can support any Waffle Takeout customers who want to build custom integrations from Waffle data.
- Easily upgrade permissions
  - Often, users would login with public-only scope and not see all their data. You can now upgrade your permissions from the project dropdown and from your user dashboard.
