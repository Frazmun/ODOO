##########################################
##  STA-PRODUCT-1 OODO App
##  Customer Webservers
##########################################
#  This will setup the webservers for a single
#  installation of OODO in the customers 
#  private VPC.
###########################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "template_file" "nginx-config" {
  template = "${file("Nginx.tpl")}"
  vars = {
    domainname = aws_instance.Webserver1.public_dns
  }
}

resource "null_resource" "Nginx" {  
  depends_on = [aws_instance.Webserver1]

  provisioner "file" {
    destination = "/home/ubuntu/Nginx.tpl"
    content      = data.template_file.nginx-config.rendered 

    connection {
      host        = aws_instance.Webserver1.public_dns
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }
}

resource "null_resource" "FinalSteps" {  
  depends_on = [null_resource.Nginx]

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8069",
      "sudo iptables-save",
      "sudo cp /home/ubuntu/Nginx.tpl /etc/nginx/sites-available/odoo.conf",
      "sudo ln -s /etc/nginx/sites-available/odoo.conf /etc/nginx/sites-enabled/odoo.conf",
      #"sudo service nginx restart",
    ]

  connection {
      host        = aws_instance.Webserver1.public_dns
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

}

resource "aws_instance" "Webserver1" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = var.ec2_instance_type
  iam_instance_profile                 = aws_iam_instance_profile.EC2profilerole_terra.name
  availability_zone                    = "eu-west-2a"
  vpc_security_group_ids               = [aws_security_group.WebserverSG.id]
  subnet_id                            = aws_subnet.PublicSubnet1.id
  key_name                             = var.ssh_key
  associate_public_ip_address          = true
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
  }

  tags = {
    Name = var.environment_name
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb",
      "sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb -y",
      "wget -O - https://nightly.odoo.com/odoo.key | sudo apt-key add -",
      "echo ${"deb http://nightly.odoo.com/13.0/nightly/deb/ ./"} | sudo tee /etc/apt/sources.list.d/odoo.list",
      "sudo apt update",
      "sudo apt install odoo -y",
      "sudo systemctl enable --now odoo",
      "touch /home/ubuntu/odoo.conf",
      "echo \"[options]\" >> /home/ubuntu/odoo.conf",
      "echo \"db_host = ${aws_db_instance.CustomerDB.address}\" >> /home/ubuntu/odoo.conf",
      "echo \"db_port = ${aws_db_instance.CustomerDB.port}\" >> /home/ubuntu/odoo.conf",
      "echo \"db_user = ${aws_db_instance.CustomerDB.username}\" >> /home/ubuntu/odoo.conf",
      "echo \"db_password = ${aws_db_instance.CustomerDB.password}\" >> /home/ubuntu/odoo.conf",      
      "sudo service odoo restart",
      "sudo apt install nginx -y",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo rm /etc/nginx/sites-available/default",
    ]

    connection {
      host        = self.public_dns
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

}
output "server_domain" {
  value = aws_instance.Webserver1.public_dns
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_key_path} ubuntu@${aws_instance.Webserver1.public_dns}"
}

output "web_url" {
  value = "http://${aws_instance.Webserver1.public_dns}"
}

