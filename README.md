# Ansible-Drupal: deployments

<br>
<br>
<p align="center">

<img src="tools/assets/images/cover.jpg" width="650">

</p>

### 🚧 **Description**

This project facilitates the deployment of Drupal applications to remote servers hosted on Okitup using Ansible. It automates the setup and configuration process, ensuring a smooth deployment workflow.
<br>
<br>

## Prerequisites

Before getting started, ensure the following prerequisites are met:

- Ansible installed on your local machine. Follow the instructions. [Ansible-drupal](https://intranet.tothomweb.com/node/342)
- Ansistrano deploy installed on your local machine. Follow the instructions. [Ansistrano-deploy](https://github.com/ansistrano/deploy)
- Basic understanding of Drupal project structure and deployment processes.

<br>
<br>

## Dependencies

This project was bootstrapped with [Ansible](https://docs.ansible.com/ansible/latest/index.html) and [Ansistrano Deploy](https://github.com/ansistrano/deploy), as a template. Also, we used the [opdavies role](https://github.com/opdavies/ansible-role-drupal-settings)

<br>
<br>

## Usage

1. **Download installer:**

   - Run this command in your Drupal root in order to download the bash file.
     `mkdir -p ~/.bin && curl -o ~/.bin/ansible-installer.sh https://raw.githubusercontent.com/webfer/ansible-drupal/main/scripts/ansible-installer.sh && source ~/.bin/ansible-installer.sh && autorun`
     This file contains custom code snippets to install this application into your Drupal project.

2. **Install this application in your Drupal root:**

   - Run the following command to install Ansible within your Drupal project:
     `ansible-install`

   **Fantastic!** You have successfully cloned the configuration, along with the necessary Ansible files, onto your local machine for deployment.

<br>
<br>

## Setting up Ansible with real project and remote server data.

To provide Ansible with the actual server data. Follow these steps:

Within your project, locate the following directories and files:

<img src="tools/assets/images/ansible-structure.png" width="650">

1. **Tools / Ansible**

   - The _Tools > Ansible_ is the root directory inside of your Drupal project.

2. **provision_vault.yml**

   - The _provision_vault.yml_ file contains all variables for your connection between the local machine to the remote server.

3. **ansible.cf**

   - The _ansible.cf_ file contains additional configuration to make Ansible work as expected.

4. **vault_pass.txt**
   - The _vault_pass.txt_ file contains the pass to encrypt/decrypt the provision_vault.yml file.

<br>
<br>

## Initial deployment

These are the allowed options:

**--stage** Deploys the site to a STAGE environment using a basic Auth, also, using an .htpasswd file.

**--live** Deploys the site to a LIVE environment

**--install** Deploys the site for the first time, including a complete database import.

**--update** Deploys the changes made since the last deployment, and updates the database with a configuration import.

**--with-assets** (Optional) Deploys and synchronizes the with-assets from the local machine to the remote server. This option ensures that files deleted locally are also deleted on the remote server.
<br>
For initial deployment in the staging environment without assets, run this command in your terminal:
`ansible-deploy --stage --install`
The above command will deploy without including the assets folder.
<br>
For initial deployment in the staging environment with assets, run this command in your terminal:
`ansible-deploy --stage --install --with-assets`
The above command will deploy including the assets folder.

## Regular deployment

For regular deployment, run in your terminal this command:
`ansible-deploy --stage --update `

<br>
<br>

## Contributing

This Ansible custom application is specifically designed to streamline Drupal deployments for a particular company, enabling efficient deployment processes to Okitup remote servers. It offers a tailored solution to meet the unique requirements of the company's deployment workflows, ensuring consistency and reliability in the deployment process.

We encourage you to explore and utilize this application for your deployment needs. If you find it beneficial and wish to contribute to its development, your participation would be greatly appreciated. By collaborating, we can enhance the functionality and robustness of this application, benefiting the broader community and fostering a spirit of shared innovation.

We welcome all contributions! Please fork the repository, make your changes, and submit a pull request.

<br>
<br>

## License

This project is licensed under the [MIT License](https://mit-license.org/).
