CREATE TABLE "User" (
    "userID"        int            NOT NULL,
    "userName"      varchar(100)   NOT NULL,
    "userPassword"  varchar(100)   NOT NULL,

    CONSTRAINT "pk_User" PRIMARY KEY (
        "userID"
     )
);

-- junction table for Users and Team table
CREATE TABLE "UserTeam" (
    "userTeamID" int   NOT NULL,
    "userID"     int   NOT NULL,
    "teamID"     int   NOT NULL,

    -- 'admin', 'member'
    "role"       varchar(50)   NOT NULL,

    CONSTRAINT "pk_UserTeam" PRIMARY KEY (
        "userTeamID"
     )
);

CREATE TABLE "Team" (
    "teamID"      int            NOT NULL,
    "teamName"    varchar(100)   NOT NULL,

    CONSTRAINT "pk_Team" PRIMARY KEY (
        "teamID"
     )
);

CREATE TABLE "Project" (
    "projectID"    int           NOT NULL,
    "teamID"       int           NOT NULL,
    "projectName"  varchar(100)  NOT NULL,

    CONSTRAINT "pk_Project" PRIMARY KEY (
        "projectID"
     )
);

CREATE TABLE "Env" (
    "envID"         int   NOT NULL,
    "projectID"     int   NOT NULL,
    "envKey"        varchar(100)   NOT NULL,
    "envSecret"     varchar(100)   NOT NULL,
    CONSTRAINT "pk_Env" PRIMARY KEY (
        "envID"
     )
);

ALTER TABLE "UserTeam" ADD CONSTRAINT "fk_UserTeam_userID" FOREIGN KEY("userID")
REFERENCES "User" ("userID");

ALTER TABLE "UserTeam" ADD CONSTRAINT "fk_UserTeam_teamID" FOREIGN KEY("teamID")
REFERENCES "Team" ("teamID");

ALTER TABLE "Project" ADD CONSTRAINT "fk_Project_teamID" FOREIGN KEY("teamID")
REFERENCES "Team" ("teamID");

ALTER TABLE "Env" ADD CONSTRAINT "fk_Env_projectID" FOREIGN KEY("projectID")
REFERENCES "Project" ("projectID");

