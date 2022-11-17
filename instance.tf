#########################################################################################
# Data Source to fetch ami  image idfor Ec2 machine

# method 1

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# method-2 

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}




# EC2 machines

resource "aws_instance" "myec21" {
  instance_type = var.ec2_type
 # ami                    = data.aws_ami.ubuntu.id
   ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = aws_subnet.subnet1.id
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  user_data              = <<EOF
      #! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/Globo_logo_Vert.png /home/ec2-user/logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
EOF

}


resource "aws_instance" "myec22" {
  instance_type = var.ec2_type
 # ami                    = data.aws_ami.ubuntu.id
   ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = aws_subnet.subnet2.id
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]
  user_data              = <<EOF
      #! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/Globo_logo_Vert.png /home/ec2-user/logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
EOF

}