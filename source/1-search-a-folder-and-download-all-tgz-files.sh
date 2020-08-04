#!/bin/bash

echo
echo -e "* * * * * * * * * * * * * * * * * * * * * * * *"
echo -e "*                                             *"
echo -e "*   \e[32mwulechuan's npm package batch \e[30;43mdownloader\e[0;0m  *"
echo -e "*                                             *"
echo -e "*   \e[35mv2.0.0\e[0m                       2020-07-27   *"
echo -e "*                                             *"
echo -e "* * * * * * * * * * * * * * * * * * * * * * * *"
echo



VE_line_5='─────'
VE_line_10="${VE_line_5}${VE_line_5}"
VE_line_20="${VE_line_10}${VE_line_10}"
VE_line_30="${VE_line_20}${VE_line_10}"
VE_line_40="${VE_line_20}${VE_line_20}"
VE_line_50="${VE_line_20}${VE_line_20}${VE_line_10}"
VE_line_60="${VE_line_20}${VE_line_20}${VE_line_20}"
VE_line_80="${VE_line_60}${VE_line_20}"



function search_npm_packages_recursively_and_download_tgz_files {
    local searchingRootPath=$1 # default: '.'
    local npmRegistryURL=$2    # default: 'http://localhost:4873'

    if [ -z "$searchingRootPath" ]; then
        searchingRootPath=.
    fi

    if [ -z "$npmRegistryURL" ]; then
        npmRegistryURL='http://localhost:4873'
    fi



    # ───────────────────────────────────────────────────────────────────────────

    local tgzCacheRootFolderFullPath='/c/taobao-npm-tgz-caches'

    local shouldDryRun=0
    local shouldDebug=0
    local shouldSkipDownloadingIfTgzCacheExists=1

    # ───────────────────────────────────────────────────────────────────────────


    local tgzCacheRootFolderFullPath_newPackages="${tgzCacheRootFolderFullPath}/new"
    local tgzCacheRootFolderFullPath_knownPublishedPackages="${tgzCacheRootFolderFullPath}/known-published"

    if [ $shouldDryRun -eq 0 ]; then
        mkdir -p "${tgzCacheRootFolderFullPath_newPackages}"
        mkdir -p "${tgzCacheRootFolderFullPath_knownPublishedPackages}"
    fi

    echo
    echo
    echo
    echo -e "\e[32mSearching packages under \"\e[35m${searchingRootPath}\e[32m\"\e[0m"
    local allNodeModulesFolders=(`find  ${searchingRootPath} -name 'node_modules'`)
    local foundNodeModulesFoldersCount=${#allNodeModulesFolders[@]}

    echo -e "\e[32mSearching completed. Found \e[35m${foundNodeModulesFoldersCount}\e[32m \"\e[33mnode_module\e[32m\" folders\e[0m"
    echo
    echo
    echo

    local a_node_modules_path
    local node_modules_folder_index=0



    local shouldExit_forDebuggingPerpose=0



    for a_node_modules_path in ${allNodeModulesFolders[@]}; do
        node_modules_folder_index=$((node_modules_folder_index+1))

        local node_modules_folder_index_colorful_string="\e[33mnode_modules\e[0m folder: \e[35m${node_modules_folder_index}\e[0m/\e[33m${foundNodeModulesFoldersCount}\e[0m"

        echo -e "${VE_line_60}"
        echo -e "${node_modules_folder_index_colorful_string}:\nPATH: \e[35m${a_node_modules_path}\e[0m"
        echo -e "${VE_line_60}"
        echo
        echo
        echo

        local all_folder_sub_paths_at_level_1=(`ls -1 "${a_node_modules_path}"`)
        local all_folders_count_at_level_1=${#all_folder_sub_paths_at_level_1[@]}

        local folder_index_at_level_1=0
        local a_folder_suh_path_at_level_1

        for a_folder_suh_path_at_level_1 in ${all_folder_sub_paths_at_level_1[@]}; do
            folder_index_at_level_1=$((folder_index_at_level_1+1))

            local folder_name_at_level_1=`echo "$a_folder_suh_path_at_level_1" | sed 's|/$||'`
            local folder_full_path_at_level_1="${a_node_modules_path}/${folder_name_at_level_1}"



            local level_1_is_an_npm_scope=0
            local all_folder_sub_paths_at_level_2=($a_folder_suh_path_at_level_1)
            local all_folders_count_at_level_2=1


            local tgz_cache_folder_full_path1="${tgzCacheRootFolderFullPath_newPackages}"
            local tgz_cache_folder_full_path2="${tgzCacheRootFolderFullPath_knownPublishedPackages}"



            local package_json_full_path_at_level_1="${folder_full_path_at_level_1}/package.json"

            if [ ! -f "${package_json_full_path_at_level_1}" ]; then
                if [[ "${folder_name_at_level_1}" =~ ^@[_a-z0-9]+ ]]; then
                    echo -e "\e[34mSEEMS TO BE A SCOPE\e[0m: \e[32m${folder_name_at_level_1}\e[0m"
                    echo

                    level_1_is_an_npm_scope=1
                    all_folder_sub_paths_at_level_2=(`ls -1 "${folder_full_path_at_level_1}"`)
                    all_folders_count_at_level_2=${#all_folder_sub_paths_at_level_2[@]}

                    tgz_cache_folder_full_path1="${tgzCacheRootFolderFullPath_newPackages}/${folder_name_at_level_1}"
                    tgz_cache_folder_full_path2="${tgzCacheRootFolderFullPath_knownPublishedPackages}/${folder_name_at_level_1}"

                    if [ $shouldDryRun -eq 0 ]; then
                        mkdir -p "$tgz_cache_folder_full_path1"
                    fi
                else
                    echo -e "\e[31mINVALID (thus ignored)\e[0m: \e[32m${folder_name_at_level_1}\e[0m"
                    continue
                fi
            fi




            local folder_index_at_level_2=0
            local a_folder_suh_path_at_level_2

            for a_folder_suh_path_at_level_2 in ${all_folder_sub_paths_at_level_2[@]}; do
                if [ $shouldExit_forDebuggingPerpose -ne 0 ]; then
                    return
                fi



                folder_index_at_level_2=$((folder_index_at_level_2+1))

                local folder_name_at_level_2=`echo "$a_folder_suh_path_at_level_2" | sed 's|/$||'`
                local folder_full_path_at_level_2="${folder_full_path_at_level_1}/${folder_name_at_level_2}"

                if [ $level_1_is_an_npm_scope -eq 0 ]; then
                    folder_full_path_at_level_2="${folder_full_path_at_level_1}"
                fi



                if [ $level_1_is_an_npm_scope -eq 0 ]; then
                    echo -e "${node_modules_folder_index_colorful_string}        package: \e[35m${folder_index_at_level_1}\e[0m/\e[33m${all_folders_count_at_level_1}\e[0m"
                else
                    echo -e "${node_modules_folder_index_colorful_string}        package: \e[35m${folder_index_at_level_1}\e[0m/\e[33m${all_folders_count_at_level_1}\e[0m - \e[35m${folder_index_at_level_2}\e[0m/\e[33m${all_folders_count_at_level_2}\e[0m"
                fi

                echo -e  "${VE_line_80}"



                local package_json_full_path_at_level_2="${folder_full_path_at_level_2}/package.json"


                if [ ! -f "${package_json_full_path_at_level_2}" ]; then
                    echo -e "\e[31mINVALID (thus ignored)\e[0m: \e[32m${folder_name_at_level_2}\e[0m"
                    echo
                    echo
                    echo
                    continue
                fi



                local package_local_name="${folder_name_at_level_2}"
                local package_full_name="${package_local_name}"



                # if [ "$package_local_name" == "typescript" ]; then
                #     echo
                #     echo -e "\e[30;41mTEMP LOGIC HERE\e[0;0m"
                #     echo -e "\e[30;41mTEMP LOGIC HERE\e[0;0m"
                #     echo -e "\e[30;41mTEMP LOGIC HERE\e[0;0m"
                #     echo
                #     shouldExit_forDebuggingPerpose=1
                # else
                #     echo
                #     echo
                #     echo
                #     continue
                # fi



                if [ $level_1_is_an_npm_scope -ne 0 ]; then
                    package_full_name="${folder_name_at_level_1}/${package_local_name}"
                fi



                local all_lines_that_mentioned_version=`cat "${package_json_full_path_at_level_2}" | grep "^\s*\"version\":\s*\"[0-9]\+\.[0-9]\+\."`
                local package_version=`echo "${all_lines_that_mentioned_version}" | sed '/"[0-9\.]\+/!d' | sed 's/ \+"version": \+"//' | sed 's/",\? *$//'`



                echo -e "Package name: \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                echo -e "${VE_line_80}"



                if [ "$shouldDebug" -ne 0 ]; then
                    echo -e "[DEBUG]: folder_name_at_level_1=\"$folder_name_at_level_1\""
                    echo -e "[DEBUG]: folder_name_at_level_2=\"$folder_name_at_level_2\""
                fi



                local taobao_tgz_url="https://registry.npm.taobao.org/${package_full_name}/download/${package_full_name}-${package_version}.tgz"
                local tgz_local_cache_file_full_path1="${tgz_cache_folder_full_path1}/${package_local_name}@${package_version}.tgz"
                local tgz_local_cache_file_full_path2="${tgz_cache_folder_full_path2}/${package_local_name}@${package_version}.tgz"



                local shouldNotDownload=0
                if [ $shouldSkipDownloadingIfTgzCacheExists -ne 0 ]; then
                    if [ -f "${tgz_local_cache_file_full_path1}" ]; then
                        shouldNotDownload=1
                    fi

                    if [ -f "${tgz_local_cache_file_full_path2}" ]; then
                        shouldNotDownload=2
                    fi
                fi

                if [ $shouldNotDownload -ne 0 ]; then
                    echo -e "\e[30;42mDOWNLOADING TGZ FROM TAOBAO REGISTRY\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e "\e[32m${VE_line_40}\e[0m"
                    echo -e "RESOURCE URL: \e[32m${taobao_tgz_url}\e[0m"
                    echo

                    if [ "$shouldDryRun" -eq 0 ]; then
                        curl -L "${taobao_tgz_url}" > "${tgz_local_cache_file_full_path1}"
                    else
                        echo -e "\e[30;41m[PSUEDO ACTION]\e[0;0m curl -L \"${taobao_tgz_url}\" > \"${tgz_local_cache_file_full_path1}\""
                    fi
                else
                    echo -e "\e[30;43mDOWNLOADING SKIPPED\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e "\e[33m${VE_line_40}\e[0m"
                    echo
                fi

                echo
                echo
                echo
            done # end of 'for' loop of level 2
        done # end of 'for' loop of level 1

        echo
        echo -e "${VE_line_60}"

        echo
        echo
        echo
    done # end of 'for' loop of all "node_modules"
}



search_npm_packages_recursively_and_download_tgz_files   $*



unset -f search_npm_packages_recursively_and_download_tgz_files
unset    VE_line_5
unset    VE_line_10
unset    VE_line_20
unset    VE_line_30
unset    VE_line_40
unset    VE_line_50
unset    VE_line_60
unset    VE_line_80
