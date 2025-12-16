module "lambda_layer_common" {
  source = "terraform-aws-modules/lambda/aws"

  create_function = false
  create_layer = true
  layer_name          = "lambda-layer-common-lib"
  description         = "common library for lambda functions"
  compatible_runtimes = ["python3.10"]
  runtime             = "python3.10"
  source_path = [
    {
      path             = "./../src/layer_common"
      pip_requirements = true
      prefix_in_zip    = "python" # required to get the path correct
    }
  ]

}