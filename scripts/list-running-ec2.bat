@echo off

echo ==========================================
echo Running EC2 Instances
echo ==========================================

aws ec2 describe-instances ^
    --filters "Name=instance-state-name,Values=running" ^
    --query "Reservations[].Instances[].{InstanceId:InstanceId,Name:Tags[?Key=='Name']|[0].Value,InstanceType:InstanceType,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,State:State.Name,AvailabilityZone:Placement.AvailabilityZone}" ^
    --output table

echo.
echo ==========================================
echo EC2 inventory completed
echo ==========================================

pause