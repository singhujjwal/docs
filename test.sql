use master
go
create Login [PRODJADE\USINGH] from windows;
use WC365 
go
create user [PRODJADE\USINGH] for login [PRODJADE\USINGH] with default_schema=dbo;
ALTER ROLE EDMROLE ADD MEMBER [PRODJADE\USINGH];
grant connect to [PRODJADE\USINGH] ;
GRANT CREATE VIEW to [PRODJADE\USINGH] ;
GRANT CREATE procedure to [PRODJADE\USINGH];
GRANT CREATE FUNCTION to [PRODJADE\USINGH];
INSERT INTO MD_SITE_USER (user_id, group_id, user_name, security_level, user_name_full, user_or_group, is_external_user, is_disabled, pwd_policy_id) VALUES ('E0001', 'G0002', 'PRODJADE\USINGH', 5, null, 'U', 'Y', null, 'P1');
INSERT INTO MD_SITE_TIGHT_GROUP_MEMBER (user_id, tight_group_id) VALUES ('E0001', 'T0001');
GRANT IMPERSONATE ON USER::"PRODJADE\USINGH" TO EDM_SERVER_USER;  
