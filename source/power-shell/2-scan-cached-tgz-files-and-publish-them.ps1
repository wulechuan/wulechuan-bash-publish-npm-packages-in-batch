$version     = 'v2.5.0'
$releaseDate = '2020-08-07'
$tgz_cache_root_folder_full_path = 'C:\taobao-npm-tgz-caches'
$folder_name_of_tgz_files_known_published         = 'known-published'
$folder_name_of_tgz_files_known_failed_to_publish = 'known-failed-to-publish'
$folder_name_of_tgz_files_to_publish              = 'new'





$script:bg = $Host.UI.RawUI.BackgroundColor
$script:fg = $Host.UI.RawUI.ForegroundColor

# $VE_line_1="-"
$VE_line_1="$([char]0x2500)"
$VE_line_5="$VE_line_1$VE_line_1$VE_line_1$VE_line_1$VE_line_1"
$VE_line_10="$VE_line_5$VE_line_5"
$VE_line_20="$VE_line_10$VE_line_10"
$VE_line_30="$VE_line_20$VE_line_10"
$VE_line_40="$VE_line_30$VE_line_10"
$VE_line_50="$VE_line_40$VE_line_10"
$VE_line_60="$VE_line_50$VE_line_10"
$VE_line_80="$VE_line_40$VE_line_40"





function Write-Colorful {
    Param (
        [string]$Content,
        [string]$F,
        [string]$B,
        [switch]$Br
    )

    if ($B) {
        $Host.UI.RawUI.BackgroundColor = $B
    }

    if ($F) {
        $Host.UI.RawUI.ForegroundColor = $F
    }

    # if (!$Content) {
    #     $Br = $True
    # }

    if ($Br) {
        Write-Host            "$Content"
    } else {
        Write-Host -NoNewLine "$Content"
    }

    if ($B) {
        $Host.UI.RawUI.BackgroundColor = $script:bg
    }

    if ($F) {
        $Host.UI.RawUI.ForegroundColor = $script:fg
    }
}



function Print-App-Splash {
    Write-Colorful -Br
    Write-Colorful -Br                 ' * * * * * * * * * * * * * * * * * * * * * * * *'
    Write-Colorful -Br                 ' *                                             *'

    Write-Colorful                     ' *   '
    Write-Colorful -F 'Green'               'Wulechuan''s npm package batch '
    Write-Colorful -F 'Black' -B 'Red'                                    'publisher'
    Write-Colorful -Br                                                             '   *'

    Write-Colorful -Br                 ' *                                             *'

    Write-Colorful                     ' *   '
    Write-Colorful -F 'Red'                 $version
    Write-Colorful                                '                       '
    Write-Colorful                                                       $releaseDate
    Write-Colorful -Br                                                             '   *'

    Write-Colorful -Br                 ' *                                             *'
    Write-Colorful -Br                 ' * * * * * * * * * * * * * * * * * * * * * * * *'
    Write-Colorful -Br
}



function Publish-All-Cached-tgz-Files-to-an-NPM-Registry {
	Param (
        [string]$npm_registry_url, # default: 'http://localhost:4873'
        [bool]  $should_dry_run,   # default: false
        [bool]  $should_debug      # default: false
    )

    if (!$npm_registry_url) {
        $npm_registry_url = 'http://localhost:4873'
    }



    # $full_path_of_folder_of_tgz_files_known_published         = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_known_published"
    # $full_path_of_folder_of_tgz_files_known_failed_to_publish = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_known_failed_to_publish"
    $full_path_of_folder_of_tgz_files_to_publish              = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_to_publish"

    $all_tgz_file_names_of_non_scoped_npm_packages = Get-ChildItem `
        -Path "$full_path_of_folder_of_tgz_files_to_publish" `
        -File `
        -Filter '*.tgz'

    $all_tgz_file_sub_paths = $all_tgz_file_names_of_non_scoped_npm_packages

    $all_sub_folders_as_npm_package_scopes = Get-ChildItem `
        -Path "$full_path_of_folder_of_tgz_files_to_publish" `
        -Directory `
        -Filter '@*'

    forEach ($sub_folder_name_as_scope in $all_sub_folders_as_npm_package_scopes) {
        forEach (
            $tgz_file_name_in_single_sub_folder in Get-ChildItem `
                -Path "$full_path_of_folder_of_tgz_files_to_publish\$sub_folder_name_as_scope" `
                -File `
                -Filter '*.tgz'
        ) {
            $all_tgz_file_sub_paths += (
                "$sub_folder_name_as_scope\$tgz_file_name_in_single_sub_folder"
            )
        }
    }

    $all_tgz_files_count = $all_tgz_file_sub_paths.Count


    Write-Colorful -Br
    Write-Colorful -Br             $VE_line_80

    Write-Colorful                 'Scanned folder:   '
    Write-Colorful -Br -F 'Yellow' $full_path_of_folder_of_tgz_files_to_publish

    Write-Colorful                 'Found .tgz files: '
    Write-Colorful -Br -F 'Green'  $all_tgz_file_sub_paths.Count

    Write-Colorful -Br             $VE_line_80
    Write-Colorful -Br
    Write-Colorful -Br
    Write-Colorful -Br



    $tgz_file_global_index = 0

    forEach ($tgz_file_full_name in $all_tgz_file_names_of_non_scoped_npm_packages) {
        $tgz_file_global_index++

        Publish-a-tgz-File-to-an-NPM-Registry `
            -npm_registry_url      $npm_registry_url `
            -tgz_file_global_index $tgz_file_global_index `
            -package_scope_name    '' `
            -tgz_file_full_name    $tgz_file_full_name `
            -should_dry_run        $should_dry_run `
            -should_debug          $should_debug
    }

    forEach ($sub_folder_name_as_scope in $all_sub_folders_as_npm_package_scopes) {
        forEach (
            $tgz_file_full_name in Get-ChildItem `
                -Path "$full_path_of_folder_of_tgz_files_to_publish\$sub_folder_name_as_scope" `
                -File `
                -Filter '*.tgz'
        ) {
            $tgz_file_global_index++

            Publish-a-tgz-File-to-an-NPM-Registry `
                -npm_registry_url      $npm_registry_url `
                -tgz_file_global_index $tgz_file_global_index `
                -package_scope_name    $sub_folder_name_as_scope `
                -tgz_file_full_name    $tgz_file_full_name `
                -should_dry_run        $should_dry_run `
                -should_debug          $should_debug
        }
    }
}



function Publish-a-tgz-File-to-an-NPM-Registry {
    Param (
        [string]$npm_registry_url,      # default: 'http://localhost:4873'
        [int]   $tgz_file_global_index,
        [string]$package_scope_name,
        [string]$tgz_file_full_name,
        [bool]  $should_dry_run,        # default: false
        [bool]  $should_debug           # default: false
    )

    $matched = $tgz_file_full_name -match '(^[^@]+)@(.+).tgz$'

    if (!$matched) {
        Write-Colorful -Br -F 'Red'     $VE_line_60
        Write-Colorful     -F 'Red'     '[INVALID FILE NAME:] '
        Write-Colorful -Br -F 'Magenta'                       $tgz_file_full_name
        Write-Colorful -Br -F 'Red'     $VE_line_60
        return
    }

    $package_local_name = $Matches[1]
    $package_version    = $Matches[2]



    $tgz_file_sub_path = $tgz_file_full_name

    if (!$npm_registry_url) {
        $npm_registry_url = 'http://localhost:4873'
    }

    if ($package_scope_name) {
        $tgz_file_sub_path = "$package_scope_name\$tgz_file_full_name"
    }

    $full_path_of_folder_of_tgz_files_known_published         = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_known_published"
    $full_path_of_folder_of_tgz_files_known_failed_to_publish = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_known_failed_to_publish"
    $full_path_of_folder_of_tgz_files_to_publish              = "$tgz_cache_root_folder_full_path\$folder_name_of_tgz_files_to_publish"



    $tgz_file_full_path="$full_path_of_folder_of_tgz_files_to_publish\$tgz_file_sub_path"


    function Print-Colorful-Package-Full-Name { # Without '.tgz'
        if ($package_scope_name) {
            Write-Colorful -F 'Green' $package_scope_name
            Write-Colorful                              '\'
        }

        Write-Colorful -F 'Green' $package_local_name
        Write-Colorful                              '@'
        Write-Colorful -F 'Magenta'                   $package_version
    }

    function Move-Package-To-Folder {
        Param(
            [string]$category = 'ok',       # 'ok',    'fail'
            [string]$packageScopeName = '', # '', '@wulechuan', '@vue', '@babel', ......
            [string]$packageSourceSubPath,
            [string]$packageSourceFullPath
        )

        if (!$packageSourceSubPath) {
            Write-Host 'ERROR: $packageSourceSubPath NOT provided for function "Move-Package-To-Folder".'
            throw 1
        }

        if (!$packageSourceFullPath) {
            Write-Host 'ERROR: $packageSourceFullPath NOT provided for function "Move-Package-To-Folder".'
            throw 2
        }

        $destinationRootFolderFullPath    = $full_path_of_folder_of_tgz_files_known_published
        $themeColor = 'Green'

        if ($category -match '^fail$') {
            $destinationRootFolderFullPath = $full_path_of_folder_of_tgz_files_known_failed_to_publish
            $themeColor = 'Red'
        }

        $destinationPackageFolderFullPath = "$destinationRootFolderFullPath\$packageScopeName"


        Write-Colorful -Br        -F $themeColor $VE_line_80

        Write-Colorful -F 'Black' -B $themeColor 'MOVE THIS TO BACKUP FOLDER:'
        Write-Colorful                                                       ' '
        Write-Colorful -Br        -F $themeColor                               $packageSourceSubPath

        if (!(Test-path $destinationPackageFolderFullPath)) {
            New-Item  -ItemType 'directory'  -Path $destinationPackageFolderFullPath
        }

        Move-Item  -Path "$packageSourceFullPath"  -Destination "$destinationRootFolderFullPath\$packageSourceSubPath\"

        Write-Colorful -Br        -F $themeColor $VE_line_80
    }



    # ----- Print a sub-title for each and every package -----
    Write-Colorful     -Br
    Write-Colorful                  'Querying registry: '
    Write-Colorful     -Br -F 'Red'                     $npm_registry_url

    Write-Colorful                  'Package Index:     '
    Write-Colorful     -F 'Yellow'                      $tgz_file_global_index
    Write-Colorful                                                           '/'
    Write-Colorful -Br -F 'Magenta'                                           $all_tgz_files_count

    Write-Colorful                  'Package:           '
    Print-Colorful-Package-Full-Name
    Write-Colorful -Br

    Write-Colorful -Br "$VE_line_80"



    if ($should_debug) {
        Write-Colorful                  '[DEBUG]: $package_scope_name = '
        Write-Colorful -Br -F 'Green'   $package_scope_name

        Write-Colorful                  '[DEBUG]: $package_local_name = '
        Write-Colorful -Br -F 'Green'   $package_local_name

        Write-Colorful                  '[DEBUG]: $package_version    = '
        Write-Colorful -Br -F 'Magenta' $package_version

        Write-Colorful                  '[DEBUG]: $tgz_file_sub_path  = '
        Write-Colorful -Br -F 'Yellow'  $tgz_file_sub_path

        Write-Colorful -Br
    }

    # # querying_an_npm_package_in_a_registry \
    # #     --npm-registry-url="$npm_registry_url" \
    # #     --package-scope="$package_scope" \
    # #     --package-local-name="$package_local_name" \
    # #     --package-version="$package_version" \
    # #     --should-debug="$should_debug"

    # # local shouldPublish=$?
    # local shouldPublish=0
    # # Write-Host -e "[DEBUG]: found exact match? (1 means 'yes') $shouldPublish"


    $alreadyPublished = $False

    if ($alreadyPublished) {
        Write-Colorful -Br -B 'Red' -F 'Black' 'PUBLISHING SKIPPED'



        if ($should_dry_run) {
            Write-Colorful -Br      -F 'Red'     $VE_line_80
            Write-Colorful -B 'Red' -F 'Black'  '[PSUEDO ACTION]'
            Write-Colorful                                     ' MOVE THIS TO BACKUP FOLDER: '
            Write-Colorful -Br      -F 'Yellow'                                              $tgz_file_sub_path
            Write-Colorful -Br      -F 'Red'     $VE_line_80
        } else {
            Move-Package-To-Folder `
                -category              'ok' `
                -packageScopeName      $package_scope_name `
                -packageSourceSubPath  $tgz_file_sub_path `
                -packageSourceFullPath $tgz_file_full_path
        }

        Write-Host
        Write-Host
        Write-Host

        return
    }




    Write-Colorful -B 'Green' -F 'Black' 'PUBLISHING PACKAGE'
    Write-Colorful                                          ' '
    Print-Colorful-Package-Full-Name
    Write-Colorful -Br

    if ($should_dry_run) {
        Write-Colorful -Br        -F 'Red'    $VE_line_80
        Write-Colorful -F 'Black' -B 'Red'    '[PSUEDO ACTION]'
        Write-Colorful                                         ' npm publish --registry="'
        Write-Colorful            -F 'Yellow'                                            $npm_registry_url
        Write-Colorful                                                                                   '" "'
        Write-Colorful            -F 'Green'                                                                 $tgz_file_full_path
        Write-Colorful -Br                                                                                                     '"'
        Write-Colorful -Br        -F 'Red'    $VE_line_80
    } else {
        Write-Colorful -Br      -F 'Green'  $VE_line_80
        Write-Colorful                      'npm publish --registry="'
        Write-Colorful          -F 'Yellow'                          $npm_registry_url
        Write-Colorful                                                               '" "'
        Write-Colorful          -F 'Green'                                               $tgz_file_full_path
        Write-Colorful -Br                                                                                 '"'
        Write-Colorful -Br      -F 'Green'  $VE_line_80

        npm  publish  --registry="$npm_registry_url"  "$tgz_file_full_path"

        if ($?) {
            Move-Package-To-Folder `
                -category              'ok' `
                -packageScopeName      $package_scope_name `
                -packageSourceSubPath  $tgz_file_sub_path `
                -packageSourceFullPath $tgz_file_full_path
        } else {
            Move-Package-To-Folder `
                -category              'fail' `
                -packageScopeName      $package_scope_name `
                -packageSourceSubPath  $tgz_file_sub_path `
                -packageSourceFullPath $tgz_file_full_path
        }
    }

    Write-Host
    Write-Host
    Write-Host
}





Print-App-Splash

Publish-All-Cached-tgz-Files-to-an-NPM-Registry `
    -npm_registry_url '' `
    -should_dry_run $False `
    -should_debug   $False
