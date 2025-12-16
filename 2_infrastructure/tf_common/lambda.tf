module "lambda_layer_common" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true
  layer_name          = "lambda-layer-common-lib"
  description         = "lambda-layer-common-lib"
  compatible_runtimes = ["python3.10"]
  source_path = "./../src/layer_common"
}