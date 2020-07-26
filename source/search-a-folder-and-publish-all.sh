#!/bin/bash

function searchRecursivelyAndPublishAll {
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



    local VE_line_5='─────'
    local VE_line_10="${VE_line_5}${VE_line_5}"
    local VE_line_20="${VE_line_10}${VE_line_10}"
    local VE_line_50="${VE_line_20}${VE_line_20}${VE_line_10}"
    local VE_line_60="${VE_line_20}${VE_line_20}${VE_line_20}"

    # ───────────────────────────────────────────────────────────────────────────



    if [ $shouldDryRun -eq 0 ]; then
        mkdir -p "${tgzCacheRootFolderFullPath}"
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


            local tgz_cache_folder_full_path="${tgzCacheRootFolderFullPath}"



            local package_json_full_path_at_level_1="${folder_full_path_at_level_1}/package.json"

            if [ ! -f "${package_json_full_path_at_level_1}" ]; then
                if [[ "${folder_name_at_level_1}" =~ ^@[_a-z0-9]+ ]]; then
                    echo -e "\e[34mSEEMS TO BE A SCOPE\e[0m: \e[32m${folder_name_at_level_1}\e[0m"
                    echo

                    level_1_is_an_npm_scope=1
                    all_folder_sub_paths_at_level_2=(`ls -1 "${folder_full_path_at_level_1}"`)
                    all_folders_count_at_level_2=${#all_folder_sub_paths_at_level_2[@]}

                    tgz_cache_folder_full_path="${tgzCacheRootFolderFullPath}/${folder_name_at_level_1}"

                    if [ $shouldDryRun -eq 0 ]; then
                        mkdir -p "$tgz_cache_folder_full_path"
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

                echo -e  "${VE_line_60}"



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
                echo -e "${VE_line_60}"



                if [ "$shouldDebug" -ne 0 ]; then
                    echo -e "[DEBUG]: folder_name_at_level_1=\"$folder_name_at_level_1\""
                    echo -e "[DEBUG]: folder_name_at_level_2=\"$folder_name_at_level_2\""
                fi



                local allSearchingResults=$(npm  search\
                    --registry="${npmRegistryURL}"\
                    --no-description\
                    --parseable "${package_full_name}"\
                    | sed    's/\t[^\t]\+$//g'\
                    | sed    's/\t=[^\t]\+//g'\
                    | sed    's/\t[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}//'\
                    | sed    's/\s\+$//'\
                    | grep   "^${package_full_name}\s"\
                    | sed -e 's/.*/"&"/'
                )

                echo
                eval allSearchingResults=(${allSearchingResults})

                if [ "$shouldDebug" -ne 0 ]; then
                    # echo -e "[DEBUG]: allSearchingResultsLength=${#allSearchingResults}"
                    echo -e "[DEBUG]: allSearchingResultsCount=${#allSearchingResults[@]}"
                    echo -e "[DEBUG]: allSearchingResults=${allSearchingResults[@]}"
                    echo
                fi

                local shouldPublish=1

                if [ ${#allSearchingResults[@]} -ne 0 ]; then
                    local searchingSingleResultSingleSegment

                    for searchingSingleResultSingleSegment in ${allSearchingResults[@]}; do
                        if [[ "$searchingSingleResultSingleSegment" =~ ${package_full_name} ]]; then
                            continue
                        fi

                        local searchingResultVersion=${searchingSingleResultSingleSegment}

                        # if [ "$shouldDebug" -ne 0 ]; then
                        #     echo -e "[DEBUG]: searchingResultVersion=\"$searchingResultVersion\""
                        # fi

                        if [ "${package_version}" == "${searchingResultVersion}" ]; then
                            echo -e "\e[30;41m${npmRegistryURL}\e[0;0m \e[31mALREADY EXISTS:         \e[32m${package_full_name}\e[0m@\e[31m${searchingResultVersion}\e[0m"
                            shouldPublish=0
                        else
                            echo -e "\e[30;44m${npmRegistryURL}\e[0;0m \e[34mEXISTS ANOTHER VERSION: \e[32m${package_full_name}\e[0m@\e[34m${searchingResultVersion}\e[0m"
                        fi
                    done
                fi



                if [ $shouldPublish -ne 1 ]; then
                    echo
                    # echo -e  "\e[31m${VE_line_10:0:7}\e[0m"
                    echo -e "\e[30;41mPUBLISHING SKIPPED\e[0;0m"
                    echo -e  "\e[31m${VE_line_50}\e[0m"
                    echo
                    echo
                    echo
                    continue
                fi



                local taobao_tgz_url="https://registry.npm.taobao.org/${package_full_name}/download/${package_full_name}-${package_version}.tgz"
                local tgz_local_cache_file_full_path="${tgz_cache_folder_full_path}/${package_local_name}-${package_version}.tgz"


                local shouldDownload=1
                if [ $shouldSkipDownloadingIfTgzCacheExists -ne 0 ]; then
                    if [ -f "${tgz_local_cache_file_full_path}" ]; then
                        shouldDownload=0
                    fi
                fi

                if [ $shouldDownload -ne 0 ]; then
                    echo -e "\e[32m${VE_line_50}\e[0m"
                    echo -e "\e[30;42mDOWNLOADING TGZ FROM TAOBAO REGISTRY\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e "\e[32m${VE_line_50}\e[0m"
                    echo -e "RESOURCE URL: \e[32m${taobao_tgz_url}\e[0m"
                    echo
                else
                    echo -e "\e[33m${VE_line_50}\e[0m"
                    echo -e "\e[30;43mDOWNLOADING SKIPPED\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e "\e[33m${VE_line_50}\e[0m"
                    echo
                fi

                if [ "$shouldDryRun" -eq 0 ]; then
                    curl -L "${taobao_tgz_url}" > "${tgz_local_cache_file_full_path}"
                else
                    echo -e "\e[30;41m[PSUEDO ACTION]\e[0;0m curl -L \"${taobao_tgz_url}\" > \"${tgz_local_cache_file_full_path}\""
                fi



                echo
                echo -e  "\e[32m${VE_line_50}\e[0m"
                echo -e "\e[30;42mnpm publishing\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                echo -e  "\e[32m${VE_line_50}\e[0m"

                if [ "$shouldDryRun" -eq 0 ]; then
                    npm  publish  --registry="${npmRegistryURL}"  "${tgz_local_cache_file_full_path}"
                else
                    echo -e "\e[30;41m[PSUEDO ACTION]\e[0;0m npm publish --registry=\"${npmRegistryURL}\" \"${tgz_local_cache_file_full_path}\""
                fi

                echo -e  "\e[32m${VE_line_50}\e[0m"

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



    unset -f searchRecursivelyAndPublishAll
}



searchRecursivelyAndPublishAll  $*
