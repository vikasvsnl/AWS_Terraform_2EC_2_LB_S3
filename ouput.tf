output "aws_alb_public_dns" {
    value = aws_lb.ngnix.dns_name
  
}