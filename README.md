# VMwareLinkedCLones
Automated Deployment of Linked Clones in VMware vSphere Environment

## Description

This PowerShell script provides a simple and efficient solution to automate the deployment of linked clones in a VMware vSphere environment. Linked clones are a smart approach to saving disk space and speeding up virtual machine deployment by sharing virtual hard disks (VMDKs) among multiple machines.

## Key Features

- **Rapid Deployment:** Automate the tedious process of deploying linked clones in just a few lines of code.
- **Customizable:** Easily configure deployment parameters such as the template name, the number of desired clones, the resource pool, the datastore, and the destination folder.
- **Resource Management:** Maximize the utilization of your infrastructure by reducing the required disk space for each clone while maintaining optimal performance.
- **vSphere Integration:** Utilize vSphere APIs for seamless integration with your existing VMware environment.

## Usage

1. Ensure you have the VMware PowerCLI modules installed and configured on your machine.
2. Run the `LinkedClonesWizard.ps1` script specifying appropriate parameters such as the template name to clone, the name, and characteristics of the new virtual machines.
3. Sit back and relax! Your linked clones will be deployed quickly and efficiently.

**Note:** Make sure to understand the implications and performance requirements of linked clones before deploying them in your production environment. Consult VMware's official documentation for more information.

## Author

Philippe PEREIRA - Infrastructure Engineer - University of Technology of Troyes

## License

MIT License

## Screeshots

![Menu principal] (https://drive.google.com/file/d/1UHPFwq9LmyEoStjEX933xFhtB0oz9zV9/view?usp=sharing)

