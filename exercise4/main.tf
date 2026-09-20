  
module "web01" {
  source = "./modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  ec2_sg        = var.ec2_sg
  instance_name = "srv01"
  environment   = var.environment

}

module "web02" {

  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  ec2_sg        = var.ec2_sg
  instance_name = "srv02"
  environment   = var.environment
}


module "s3" {

  source = "./modules/s3"

  bucket_name = var.bucket_name
  environment = var.environment
}
