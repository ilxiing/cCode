-- https://leetcode-cn.com/problems/trips-and-users/ 

/**
解题思路:
    1. 统计状态为 cancel 的记录数量 sum(Status<>'completed')
    2. 统计每个 group 的总记录数 count(*), 因为有通过 group by Request_at
    3. 通过连接 users 表过滤出 Trips 非禁止用户的记录
*/

O(n4)
select Request_at as 'Day', round(sum(Status<>'completed') / count(*), 2) as 'Cancellation Rate'
from (
    select Request_at, Status
    from Trips
    where Client_Id not in (select Users_id from Users where Banned='Yes' and Role='client')
    and Driver_Id not in (select Users_id from Users where Banned='Yes' and Role='driver')
    and Request_at between '2013-10-01' and '2013-10-03'
) t
group by Request_at


O(n)
select Request_at as 'Day', round(sum(Status<>'completed') / count(*), 2) as 'Cancellation Rate'
from Trips t
join Users u1 on t.Client_Id=u1.Users_Id and u1.Role='client' and u1.Banned!='Yes'
join Users u2 on t.Driver_Id=u2.Users_Id and u2.Role='driver' and u2.Banned!='Yes'
where t.Request_at between '2013-10-01' and '2013-10-03'
group by t.Request_at