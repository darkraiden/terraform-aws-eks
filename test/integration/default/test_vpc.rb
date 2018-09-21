# frozen_string_literal: true

require 'awspec'
require 'aws-sdk'
require 'rhcl'

# should strive to randomize the region for more robust testing
example_main = Rhcl.parse(File.open('test/test_fixture/main.tf'))
eks_name = example_main['module']['eks']['eks_name']
vpc_name = "#{eks_name}-vpc"
state_file = 'terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)
region = "us-east-1"
ENV['AWS_REGION'] = region

ec2 = Aws::EC2::Client.new(region: region)
azs = ec2.describe_availability_zones
zone_names = azs.to_h[:availability_zones].map { |az| az[:zone_name] }

describe vpc(vpc_name.to_s) do
  it { should exist }
  it { should be_available }
  it { should have_tag('Name').value(vpc_name.to_s) }
  it { should have_route_table("#{eks_name}-public-route-table") }
  it { should have_route_table("#{eks_name}-private-route-table") }
end

# zone_names.each_with_index do |az, index|
#   describe subnet("#{environment_tag.to_s}-public-subnet-#{index}") do
#     it { should exist }
#     it { should be_available }
#     it { should belong_to_vpc(vpc_name.to_s) }
#     it { should have_tag('Name').value("#{environment_tag}-public-subnet-#{index}") }
#     it { should have_tag('Environment').value(environment_tag.to_s) }
#   end

#   describe subnet("#{environment_tag.to_s}-private-subnet-#{index}") do
#     it { should exist }
#     it { should be_available }
#     it { should belong_to_vpc(vpc_name.to_s) }
#     it { should have_tag('Name').value("#{environment_tag}-private-subnet-#{index}") }
#     it { should have_tag('Environment').value(environment_tag.to_s) }
#   end
# end
