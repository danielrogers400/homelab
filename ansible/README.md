# Homelab Infrastructure Automation

## Prerequisites

- Ansible 2.10+
- Python 3.8+
- SSH access to target hosts

## Setup

1. Install required collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

2. Configure inventory:
- Edit `inventory/hosts` with your cluster details
- Customize `inventory/group_vars/all.yml` as needed

## Running Playbooks

### Full Infrastructure
```bash
ansible-playbook playbooks/full-infrastructure.yml
```

### Individual Components
```bash
# Install only MetalLB
ansible-playbook playbooks/metallb.yml
```

## Customization

- Add new roles in the `roles/` directory
- Create additional playbooks in the `playbooks/` directory
- Modify group variables to suit your infrastructure