$script:SlackApiToken = $env:SlackAPIToken

function Send-SlackApi {
    param (
        $Method,
        $Body = @{},
        $Token = $script:SlackApiToken
    )
    $Body.token = $Token
    irm "https://slack.com/api/$method" -body $body
}

function Get-SlackStatus {
    param ($User)
    Send-SlackApi -method users.getPresence -body @{user=$User}
}

function Set-SlackAway {
    Send-SlackApi -method users.setPresence -body @{presence='away'}
}

function Set-SlackAuto {
    Send-SlackApi -method users.setPresence -body @{presence='auto'}
}

function Send-SlackMessage {
  param (
      $text,
      $channel,
      $username, 
      $iconurl, 
      [switch]$AsUser
  )
  end {
    $body = @{
      as_user = $AsUser
      channel = $channel
    }

    switch ($psboundparameters.keys) {
      'text'     {$body.text     = $text}
      'username' {$body.username = $username}
      'iconurl'  {$body.icon_url = $iconurl}
    }

    $response = Send-SlackApi -method chat.postMessage -body $body
    
    if ($response.ok) {
      $link = "https://chefio.slack.com/archives/$($response.channel)/" +
        "p$($response.ts -replace '\.')"
      $response | 
        add-member -membertype NoteProperty -Name link -Value $link
    }

    $response
  }
}

function Get-SlackApiToken {
  $script:SlackApiToken
}

function Set-SlackApiToken {
  param ($token)
  $script:SlackApiToken = $token
}
