# Ansible-Drupal: Mini-Application to manage Drupal deployments

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

- Ansible installed on your local machine. Follow the instructions in the following tutorial. [Ansible-drupal tutorial](https://intranet.tothomweb.com/node/342)
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
     `curl -o installer.sh https://raw.githubusercontent.com/webfer/ansible-drupal/main/scripts/installer.sh`
     This file contains custom code snippets to install this mini-application into your Drupal project.

2. **Give permissions:**

   - Make sure to give execute permissions to the downloaded file. To do this, run the following command:
     `chmod +x installer.sh`

3. **Install this application in your Drupal root:**

   - Run the following command to install Ansible within our Drupal project:
     `sudo ./installer.sh`
     Provide the password for your local machine.
     Note! Since it's an executable bash file, your local machine will prompt you for the password.

   Fantastic! You've now cloned the configuration with the necessary Ansible files onto your local machine for deployment.

<br>
<br>

## Setting up Ansible with real project and remote server data.

To provide Ansible with the actual server data. Follow these steps:

Within your project, locate the following directories and files:

<img src="tools/assets/images/ansible-structure.png" width="650">

1. **Tools / Ansible**

   - The Tools > Ansible is the root directory inside of your Drupal project.

2. **provision_vault.yml**

   - The provision_vault.yml file contains all variables for your connection between the local machine to the remote server.

3. **ansible.cf**

   - The ansible.cf file contains additional configuration to make Ansible work as expected.

4. **vault_pass.txt**
   - The vault_pass.txt file contains the pass to encrypt/decrypt the provision_vault.yml file.

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
