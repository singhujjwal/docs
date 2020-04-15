use master
go
create Login [PRODJADE\DBARNEVELD] from windows;
use WC365 
go
create user [PRODJADE\DBARNEVELD] for login [PRODJADE\DBARNEVELD] with default_schema=dbo;
ALTER ROLE EDMROLE ADD MEMBER [PRODJADE\DBARNEVELD];
grant connect to [PRODJADE\DBARNEVELD] ;
GRANT CREATE VIEW to [PRODJADE\DBARNEVELD] ;
GRANT CREATE procedure to [PRODJADE\DBARNEVELD];
GRANT CREATE FUNCTION to [PRODJADE\DBARNEVELD];
INSERT INTO MD_SITE_USER (user_id, group_id, user_name, security_level, user_name_full, user_or_group, is_external_user, is_disabled, pwd_policy_id) VALUES ('E0001', 'G0002', 'PRODJADE\DBARNEVELD', 5, null, 'U', 'Y', null, 'P1');
INSERT INTO MD_SITE_TIGHT_GROUP_MEMBER (user_id, tight_group_id) VALUES ('E0001', 'T0001');
GRANT IMPERSONATE ON USER::"PRODJADE\DBARNEVELD" TO EDM_SERVER_USER;  
