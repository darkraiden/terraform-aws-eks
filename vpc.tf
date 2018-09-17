#########
## VPC ##
#########

resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr_block}"
  instance_tenancy = "${var.vpc_instance_tenancy}"

  tags = "${
    merge(
      map("Name", format("%s-vpc", var.eks_name)),
      map(format("kubernetes.io/cluster/%s", var.eks_name), "shared"),
      var.vpc_tags
    )
  }"
}

#############
## Subnets ##
#############

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count             = "${var.public_subnets_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 101)}"

  tags = "${
    merge(
      map("Name", format("%s-public-subnet-%d", var.eks_name, count.index)),
      map(format("kubernetes.io/cluster/%s", var.eks_name), "shared"),
      var.public_subnets_tags
    )
  }"
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = "${var.private_subnets_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)}"

  tags = "${
    merge(
      map("Name", format("%s-private-subnet-%d", var.eks_name, count.index)),
      map(format("kubernetes.io/cluster/%s", var.eks_name), "shared"),
      var.private_subnets_tags
    )
  }"
}

############
## Router ##
############

resource "aws_route_table" "public-route-table" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_internet_gateway.igw"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = "${
    merge(
      map("Name", format("%s-public-route-table", var.eks_name))
    )
  }"
}

resource "aws_route_table_association" "public-route-table-association" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}

resource "aws_route_table" "private-route-table" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_nat_gateway.nat"]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = "${
    merge(
      map("Name", format("%s-private-route-table", var.eks_name))
    )
  }"
}

resource "aws_route_table_association" "private-route-table-association" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}

##############
## Gateways ##
##############

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${
    merge(
      map("Name", format("%s-vpc-igw", var.eks_name))
    )
  }"
}

# Nat Gateway IP
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"
  depends_on    = ["aws_eip.nat_eip"]
}
