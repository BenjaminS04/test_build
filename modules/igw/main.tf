# creates internet gateway(igw), selects vpc for igw and uses tags to name it
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "i-${var.gateway_name}"
  }

}

# creates a route table for the subnet
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.gateway_name}-route-table"
  }
}

# associates the subnet with the route table
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.route_table.id
}