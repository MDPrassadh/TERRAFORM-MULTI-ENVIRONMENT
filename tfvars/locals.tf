# locals {
#   httpd_script = <<-EOF
#     #!/bin/bash
#     dnf update -y
#     dnf install -y httpd
#     systemctl enable httpd
#     systemctl start httpd
#     echo "<h1> Welcome to Frontend via Terraform + Apache Mr prassadh </h1>" > /var/www/html/index.html
#   EOF
# }



# # Helper: ensure user_data is always plain text
# locals {
#   # If your script is already base64, keep it as-is.
#   # Otherwise, encode it here so you can safely use user_data_base64.
#   httpd_script_encoded = (
#     substr(local.httpd_script, 0, 2) == "#!"
#     ? base64encode(local.httpd_script)   # plain text script → encode
#     : local.httpd_script                 # already base64 → leave unchanged
#   )
# }
