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

    local VE_line_5='─────'
    local VE_line_10="${VE_line_5}${VE_line_5}"
    local VE_line_20="${VE_line_10}${VE_line_10}"
    local VE_line_50="${VE_line_20}${VE_line_20}${VE_line_10}"
    local VE_line_60="${VE_line_20}${VE_line_20}${VE_line_20}"

    # ───────────────────────────────────────────────────────────────────────────



    echo -e "\e[32mSearching from \"\e[35m${searchingRootPath}\e[32m\"...\e[0m"
    local allNodeModulesFolders=(`find  ${searchingRootPath} -name 'node_modules'`)
    local foundNodeModulesFoldersCount=${#allNodeModulesFolders[@]}

    echo -e "\e[32mSearching completed. Found \e[35m${foundNodeModulesFoldersCount}\e[32m \"node_module\" folders\e[0m"
    echo -e "${VE_line_60}"
    echo

    local a_node_modules_path
    local node_modules_folder_index=0

    for a_node_modules_path in ${allNodeModulesFolders[@]}; do
        node_modules_folder_index=$((node_modules_folder_index+1))

        local node_modules_folder_index_colorful_string="\e[33mnode_modules\e[0m folder: \e[35m${node_modules_folder_index}\e[0m/\e[33m${foundNodeModulesFoldersCount}\e[0m"

        echo -e "${VE_line_60}"
        echo -e "${node_modules_folder_index_colorful_string}:    \e[35m${a_node_modules_path}\e[0m"
        echo -e "${VE_line_60}"
        echo
        echo
        echo

        local packPaths=(`ls -1 "${a_node_modules_path}"`)
        local foundPacksCount=${#packPaths[@]}
        local a_pack_path
        local pack_index=0

        for a_pack_path in ${packPaths[@]}; do
            local a_pack_path_string_length=${#a_pack_path}
            local a_pack_path_sliced_length=$((a_pack_path_string_length-1))
            local a_pack_path_no_slash_suffix=${a_pack_path:0:a_pack_path_sliced_length}
            local package_name=$a_pack_path_no_slash_suffix

            local package_full_path="${a_node_modules_path}/${a_pack_path_no_slash_suffix}"

            pack_index=$((pack_index+1))

            local packageJSONFullPath="${package_full_path}/package.json"

            echo -en "${node_modules_folder_index_colorful_string}"
            echo -e  "            package: \e[35m${pack_index}\e[0m/\e[33m${foundPacksCount}\e[0m"
            echo -e  "${VE_line_60}"

            if [ ! -f "${packageJSONFullPath}" ]; then
                echo -e "\e[31mINVALID (thus ignored)\e[0m: \e[32m${package_name}\e[0m"
            else
                local packageVersionLines=`cat "${packageJSONFullPath}" | grep "^\s*\"version\":\s*\"[0-9]\+\.[0-9]\+\."`
                local package_version=`echo "${packageVersionLines}" | sed '/"[0-9\.]\+/!d' | sed 's/ \+"version": \+"//' | sed 's/",\? *$//'`
                # echo "package_version=\"${package_version}\""

                echo -e "Package in the \e[33mnode_modules\e[0m folder:   \e[32m${package_name}\e[0m@\e[35m${package_version}\e[0m"
                echo -e  "${VE_line_60}"

                npm  search\
                    --no-description\
                    --parseable "${package_name}"\
                    --registry="${npmRegistryURL}"\
                    | sed  's/\t[^\t]\+$//g'\
                    | sed  's/\t=[^\t]\+//g'\
                    | sed  's/\t[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}//'\
                    | sed  's/\t$//'\
                    | grep "^${package_name}\s"\
                    > ~/wlc-npm-search-result.tmp

                local searchingResult=`head -n 1 ~/wlc-npm-search-result.tmp`
                rm -f ~/wlc-npm-search-result.tmp
                # echo "searchingResult=\"$searchingResult\""

                local shouldPublish=0

                if [ -z "$searchingResult" ]; then
                    shouldPublish=1
                else
                    local searchingResultVersion=`echo "${searchingResult}" | sed 's/^[^\t]\+\t//'`
                    # echo -e "\e[30;42m${npmRegistryURL}\e[0;0m \e[32mFOUND VERSION: \e[33m${package_name}\e[0m@\e[35m${searchingResultVersion}\e[0m"

                    if [ "${package_version}" == "${searchingResultVersion}" ]; then
                        echo -e "\e[30;41m${npmRegistryURL}\e[0;0m \e[31mALREADY EXISTS: \e[32m${package_name}\e[0m@\e[35m${searchingResultVersion}\e[0m"
                    else
                        echo -e "\e[30;42m${npmRegistryURL}\e[0;0m \e[34mEXISTS ANOTHER VERSION: \e[34m${package_name}\e[0m@\e[35m${searchingResultVersion}\e[0m"
                        shouldPublish=1
                    fi
                fi

                if [ $shouldPublish -eq 1 ]; then
                    echo -e  "\e[32m${VE_line_50}\e[0m"
                    echo -e "\e[30;42mnpm publishing\e[0;0m \e[32m${package_name}\e[0m@\e[35m${package_version}\e[0m..."
                    echo -e  "\e[32m${VE_line_50}\e[0m"
                    npm  publish  --registry="${npmRegistryURL}"  ${package_full_path}
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
