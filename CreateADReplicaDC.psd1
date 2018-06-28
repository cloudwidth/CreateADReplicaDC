$ConfigData = @{ 
    AllNodes = @( 
        @{ 
            Nodename = '*'
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = 'localhost'
        }
    );
    NonNodeData = @{
        domainName = 'dolab.com'
    }
} 