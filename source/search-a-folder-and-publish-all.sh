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

    local shouldDryRun=0
    local shouldDebug=0
    local tgzCacheFolderPath='/c/taobao-npm-tgz-caches'

    local VE_line_5='─────'
    local VE_line_10="${VE_line_5}${VE_line_5}"
    local VE_line_20="${VE_line_10}${VE_line_10}"
    local VE_line_50="${VE_line_20}${VE_line_20}${VE_line_10}"
    local VE_line_60="${VE_line_20}${VE_line_20}${VE_line_20}"

    # ───────────────────────────────────────────────────────────────────────────



    mkdir -p "${tgzCacheFolderPath}"

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

    for a_node_modules_path in ${allNodeModulesFolders[@]}; do
        node_modules_folder_index=$((node_modules_folder_index+1))

        local node_modules_folder_index_colorful_string="\e[33mnode_modules\e[0m folder: \e[35m${node_modules_folder_index}\e[0m/\e[33m${foundNodeModulesFoldersCount}\e[0m"

        echo -e "${VE_line_60}"
        echo -e "${node_modules_folder_index_colorful_string}:\n  \e[35m${a_node_modules_path}\e[0m"
        echo -e "${VE_line_60}"
        echo
        echo
        echo

        local packPaths=(`ls -1 "${a_node_modules_path}"`)
        local foundPacksCount=${#packPaths[@]}
        local a_pack_path
        local pack_index=0
        # local shouldStopWhenNextLoopBegin=0

        for a_pack_path in ${packPaths[@]}; do
            # if [ $shouldStopWhenNextLoopBegin -ne 0 ]; then return; fi

            # if [[ ! "$a_pack_path" =~ mkdirp ]]; then
            #     continue;
            # else
            #     echo TEMP CODE
            #     echo TEMP CODE
            #     echo TEMP CODE
            #     echo TEMP CODE
            #     echo TEMP CODE
            #     echo TEMP CODE
            #     shouldStopWhenNextLoopBegin=1
            # fi

            local a_pack_path_string_length=${#a_pack_path}
            local a_pack_path_sliced_length=$((a_pack_path_string_length-1))
            local a_pack_path_no_slash_suffix=${a_pack_path:0:a_pack_path_sliced_length}
            local package_folder_name=$a_pack_path_no_slash_suffix

            local package_full_path="${a_node_modules_path}/${a_pack_path_no_slash_suffix}"

            pack_index=$((pack_index+1))

            local packageJSONFullPath="${package_full_path}/package.json"

            echo -en "${node_modules_folder_index_colorful_string}"
            echo -e  "            package: \e[35m${pack_index}\e[0m/\e[33m${foundPacksCount}\e[0m"
            echo -e  "${VE_line_60}"

            if [ ! -f "${packageJSONFullPath}" ]; then
                if [[ "${package_folder_name}" =~ ^@[_a-z0-9]+ ]]; then
                    echo -e "\e[34mSEEMS TO BE A SCOPE\e[0m: \e[32m${package_folder_name}\e[0m"
                else
                    echo -e "\e[31mINVALID (thus ignored)\e[0m: \e[32m${package_folder_name}\e[0m"
                fi
            else
                local packageVersionLines=`cat "${packageJSONFullPath}" | grep "^\s*\"version\":\s*\"[0-9]\+\.[0-9]\+\."`
                local package_version=`echo "${packageVersionLines}" | sed '/"[0-9\.]\+/!d' | sed 's/ \+"version": \+"//' | sed 's/",\? *$//'`

                if [ "$shouldDebug" -ne 0 ]; then
                    echo -e "[DEBUG]: package_version=\"${package_version}\""
                fi

                local parent_folder_name=`dirname  "$package_full_path"`
                parent_folder_name=`basename  "${parent_folder_name}"`

                if [ "$shouldDebug" -ne 0 ]; then
                    echo -e "[DEBUG]: parent_folder_name=\"$parent_folder_name\""
                fi

                local package_folder_name_prefix=''

                if [[ "$parent_folder_name" =~ ^@[_a-z0-9]+ ]]; then
                    package_folder_name_prefix="${parent_folder_name}/"
                fi

                local package_full_name="${package_folder_name_prefix}${package_folder_name}"

                echo -e "Package in the \e[33mnode_modules\e[0m folder:   \e[32m${package_folder_name}\e[0m@\e[35m${package_version}\e[0m"
                echo -e  "${VE_line_60}"

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
                    echo -e "\e[30;41mSKIPPED\e[0;0m"
                    echo -e  "\e[31m${VE_line_50}\e[0m"
                else
                    local taobao_tgz_url="https://registry.npm.taobao.org/${package_full_name}/download/${package_full_name}-${package_version}.tgz"

                    echo -e  "\e[32m${VE_line_50}\e[0m"
                    echo -e  "\e[30;42mdownloading tgz from taobao\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e  "\e[32m${VE_line_50}\e[0m"
                    echo -e  "RESOURCE: \e[32m${taobao_tgz_url}\e[0m"

                    if [ "$shouldDryRun" -eq 0 ]; then
                        curl -L "${taobao_tgz_url}" > "${tgzCacheFolderPath}/${package_full_name}-${package_version}.tgz"
                    else
                        echo -e "\e[30;41m[PSUEDO]\e[0;0m curl -L \"${taobao_tgz_url}\" > \"${tgzCacheFolderPath}/${package_full_name}-${package_version}.tgz\""
                    fi

                    echo -e  "\e[32m${VE_line_50}\e[0m"

                    echo -e "\e[30;42mnpm publishing\e[0;0m \e[32m${package_full_name}\e[0m@\e[35m${package_version}\e[0m"
                    echo -e  "\e[32m${VE_line_50}\e[0m"
                    # npm  publish  --registry="${npmRegistryURL}"  ${package_full_path}
                    if [ "$shouldDryRun" -eq 0 ]; then
                        npm  publish  --registry="${npmRegistryURL}"  "${tgzCacheFolderPath}/${package_full_name}-${package_version}.tgz"
                    else
                        echo -e "\e[30;41m[PSUEDO]\e[0;0m npm publish --registry=\"${npmRegistryURL}\" \"${tgzCacheFolderPath}/${package_full_name}-${package_version}.tgz\""
                    fi
                    echo -e  "\e[32m${VE_line_50}\e[0m"
                fi
            fi

            echo
            echo
            echo
        done

        echo
        echo -e "${VE_line_60}"
        echo
        echo
        echo
    done

    echo
    # echo -e "\e[32mSearching completed. Found \e[35m${foundCount}\e[32m \"node_module\" folders\e[0m"
    echo
    echo

    unset -f searchRecursivelyAndPublishAll
}

searchRecursivelyAndPublishAll  $*
