#!/bin/bash

echo
echo -e "* * * * * * * * * * * * * * * * * * * * * * * *"
echo -e "*                                             *"
echo -e "*   \e[32mwulechuan's npm package batch \e[30;41mpublisher\e[0;0m   *"
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



function querying_an_npm_package_in_a_registry {
    local query___npm_registry_url=$1    # default: 'http://localhost:4873'
    local query___package_scope=$2
    local query___package_local_name=$3
    local query___package_version=$4
    local query___should_debug=$5 # 'yes' or anything else

    if [[ "$query___npm_registry_url" =~ --npm-registry-url= ]]; then
        query___npm_registry_url=${query___npm_registry_url:19}
    fi

    if [[ "$query___package_scope" =~ --package-scope= ]]; then
        query___package_scope=${query___package_scope:16}
    fi

    if [[ "$query___package_local_name" =~ --package-local-name= ]]; then
        query___package_local_name=${query___package_local_name:21}
    fi

    if [[ "$query___package_version" =~ --package-version= ]]; then
        query___package_version=${query___package_version:18}
    fi

    if [[ "$query___should_debug" =~ --should-debug= ]]; then
        query___should_debug=${query___should_debug:15}
    fi



    if [ -z "$query___package_local_name" ]; then
        return 1
    fi

    if [ -z "$query___package_version" ]; then
        return 1
    fi



    if [ -z "$query___npm_registry_url" ]; then
        query___npm_registry_url='http://localhost:4873'
    fi



    local query___package_full_name="$query___package_local_name"

    if [ ! -z "${query___package_scope}" ]; then
        query___package_full_name="${query___package_scope}/${query___package_local_name}"
    fi



    if [ "$query___should_debug" == 'yes' ]; then
        echo -e "[DEBUG]: query___npm_registry_url=\"\e[34m${query___npm_registry_url}\e[0m\""
        echo -e "[DEBUG]: query___package_scope=\"\e[33m${query___package_scope}\e[0m\""
        echo -e "[DEBUG]: query___package_local_name=\"\e[32m${query___package_local_name}\e[0m\""
        echo -e "[DEBUG]: query___package_full_name=\"\e[32m${query___package_full_name}\e[0m\""
        echo -e "[DEBUG]: query___package_version=\"\e[35m${query___package_version}\e[0m\""
        echo -e "[DEBUG]: query___should_debug=\"\e[31m${query___should_debug}\e[0m\""
        echo
    fi



    local query___all_results=$(npm  search\
        --registry="${query___npm_registry_url}"\
        --no-description\
        --parseable "${query___package_full_name}"\
        | sed    's/\t[^\t]\+$//g'\
        | sed    's/\t=[^\t]\+//g'\
        | sed    's/\t[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}//'\
        | sed    's/\s\+$//'\
        | grep   "^${query___package_full_name}\s"\
        | sed -e 's/.*/"&"/'
    )

    echo
    eval query___all_results=(${query___all_results})

    if [ "$query___should_debug" == 'yes' ]; then
        # echo -e "[DEBUG]: query___all_resultsLength=${#query___all_results}"
        echo -e "[DEBUG]: query___all_results: COUNT=\e[35m${#query___all_results[@]}\e[0m"
        echo -e "[DEBUG]: query___all_results: ITEMS=\e[32m${query___all_results[@]}\e[0m"
        echo
    fi

    local found_an_exact_match=0

    if [ ${#query___all_results[@]} -ne 0 ]; then
        local query___result_single_term

        for query___result_single_term in ${query___all_results[@]}; do
            if [[ "$query___result_single_term" =~ ${query___package_full_name} ]]; then
                continue
            fi

            local queried_package_version=${query___result_single_term}

            # if [ "$query___should_debug" == 'yes' ]; then
            #     echo -e "[DEBUG]: queried_package_version=\"$queried_package_version\""
            # fi

            if [ "${query___package_version}" == "${queried_package_version}" ]; then
                echo -e "\e[30;41m${query___npm_registry_url}\e[0;0m         \e[31mALREADY EXISTS: \e[32m${query___package_full_name}\e[0m@\e[31m${queried_package_version}\e[0m"
                found_an_exact_match=1
            else
                echo -e "\e[30;44m${query___npm_registry_url}\e[0;0m \e[34mEXISTS ANOTHER VERSION: \e[32m${query___package_full_name}\e[0m@\e[34m${queried_package_version}\e[0m"
            fi
        done
    fi

    return $found_an_exact_match
}



function for_all_cached_tgz_files_try_publish_them_to_a_registry {
    local publishing___tgz_cache_root_folder_path=$1 # default: '/c/taobao-npm-tgz-caches'
    local publishing___npm_registry_url=$2 # default: 'http://localhost:4873'
    local publishing___should_dry_run=$3   # 'yes' or anything else
    local publishing___should_debug=$4     # 'yes' or anything else



    local publishing___exitCodeOfPreviousCommand=0

    if [[ "$publishing___tgz_cache_root_folder_path" =~ --tgz-cache-root-folder= ]]; then
        publishing___tgz_cache_root_folder_path=${publishing___tgz_cache_root_folder_path:24}
    fi

    if [[ "$publishing___npm_registry_url" =~ --npm-registry-url= ]]; then
        publishing___npm_registry_url=${publishing___npm_registry_url:19}
    fi

    if [[ "$publishing___should_dry_run" =~ --should-dry-run= ]]; then
        publishing___should_dry_run=${publishing___should_dry_run:17}
    fi

    if [[ "$publishing___should_debug" =~ --should-debug= ]]; then
        publishing___should_debug=${publishing___should_debug:15}
    fi



    if [ -z "$publishing___tgz_cache_root_folder_path" ]; then
        publishing___tgz_cache_root_folder_path='/c/taobao-npm-tgz-caches'
    fi

    if [ -z "$publishing___npm_registry_url" ]; then
        publishing___npm_registry_url='http://localhost:4873'
    fi



    local publishing___tgz_cache_known_published_packages_folder_path="${publishing___tgz_cache_root_folder_path}/known-published"
    local publishing___tgz_cache_known_packages_failed_to_publish_folder_path="${publishing___tgz_cache_root_folder_path}/known-failed-to-publish"
    local publishing___tgz_cache_known_new_packages_folder_path="${publishing___tgz_cache_root_folder_path}/new"


    local publishing___all_tgz_file_sub_paths=(`find "${publishing___tgz_cache_known_new_packages_folder_path}" -name '*.tgz'`)
    local publishing___all_tgz_files_count=${#publishing___all_tgz_file_sub_paths[@]}

    echo
    echo -e "$VE_line_80"
    echo -e "Scanned folde:   \"\e[33m${publishing___tgz_cache_known_new_packages_folder_path}\e[0m\""
    echo -e "Found .tgz files: \e[35m${publishing___all_tgz_files_count}\e[0m"
    echo -e "$VE_line_80"
    echo
    echo
    echo

    # if [ "$publishing___should_debug" == 'yes' ]; then
    #     echo -e "[DEBUG]: publishing___tgz_cache_known_new_packages_folder_path=\"${publishing___tgz_cache_known_new_packages_folder_path}\""
    #     echo -e "[DEBUG]: publishing___all_tgz_file_sub_paths=${publishing___all_tgz_files_count}"
    #     echo
    # fi



    local publishing___tgz_file_sub_path
    local publishing___tgz_file_containing_folder_sub_path
    local publishing___tgz_file_full_path
    local publishing___tgz_file_index=0

    for publishing___tgz_file_full_path in ${publishing___all_tgz_file_sub_paths[@]}; do
        publishing___tgz_file_index=$((publishing___tgz_file_index+1))

        # local publishing___tgz_file_full_path="${publishing___tgz_cache_known_new_packages_folder_path}/${publishing___tgz_file_sub_path}"

        local publishing___tgz_file_name=`basename              "${publishing___tgz_file_full_path}"`
        local publishing___tgz_file_parent_folder_name=`dirname "${publishing___tgz_file_full_path}"`
        publishing___tgz_file_parent_folder_name=`basename      "${publishing___tgz_file_parent_folder_name}"`

        publishing___tgz_file_containing_folder_sub_path=""


        local publishing___package_scope=''
        local publishing___package_local_name=`echo "${publishing___tgz_file_name}" | sed 's/@[^@]\+$//'`
        local publishing___package_version=`echo    "${publishing___tgz_file_name}" | sed 's/[^@]\+@//' | sed 's/\.tgz$//'`

        if [[ "$publishing___tgz_file_parent_folder_name" =~ ^@[_a-z0-9]+ ]]; then
            publishing___package_scope="${publishing___tgz_file_parent_folder_name}"
            publishing___tgz_file_sub_path="${publishing___package_scope}/${publishing___tgz_file_sub_path}"
            publishing___tgz_file_containing_folder_sub_path="${publishing___package_scope}/"
        fi

        publishing___tgz_file_sub_path="${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}"


        local publishing___package_full_name_with_version_colorful
        if [ -z "${publishing___package_scope}" ]; then
            publishing___package_full_name_with_version_colorful="\e[32m${publishing___package_local_name}\e[0m@\e[35m${publishing___package_version}\e[0m"
        else
            publishing___package_full_name_with_version_colorful="\e[32m${publishing___package_scope}/${publishing___package_local_name}\e[0m@\e[35m${publishing___package_version}\e[0m"
        fi


        echo
        echo -e "Querying registry: \e[33m${publishing___npm_registry_url}\e[0m"
        echo -e "Package Index:     \e[31m${publishing___tgz_file_index}\e[0m/\e[35m${publishing___all_tgz_files_count}\e[0m"
        echo -e "Package:           ${publishing___package_full_name_with_version_colorful}"
        echo -e "${VE_line_80}"

        if [ "$publishing___should_debug" == 'yes' ]; then
            echo -e "[DEBUG]: parent_folder                      =\"\e[33m${publishing___tgz_file_parent_folder_name}\e[0m\""
            echo -e "[DEBUG]: package_local_name                 =\"\e[32m${publishing___package_local_name}\e[0m\""
            echo -e "[DEBUG]: package_version                    =\"\e[35m${publishing___package_version}\e[0m\""
            echo -e "[DEBUG]: tgz_file_sub_path                  =\"\e[35m${publishing___tgz_file_sub_path}\e[0m\""
            echo -e "[DEBUG]: tgz_file_containing_folder_sub_path=\"\e[35m${publishing___tgz_file_containing_folder_sub_path}\e[0m\""
            echo
        fi



        # if [ $publishing___tgz_file_index -gt 5 ]; then
        #     echo
        #     echo -e "\e[30;41mTEMP LOGIC\e[0;0m"
        #     echo -e "\e[30;41mTEMP LOGIC\e[0;0m"
        #     echo -e "\e[30;41mTEMP LOGIC\e[0;0m"
        #     echo
        #     break
        # fi



        # querying_an_npm_package_in_a_registry \
        #     --npm-registry-url="${publishing___npm_registry_url}" \
        #     --package-scope="${publishing___package_scope}" \
        #     --package-local-name="${publishing___package_local_name}" \
        #     --package-version="${publishing___package_version}" \
        #     --should-debug="${publishing___should_debug}"

        # local publishing___should_proceed=$?
        local publishing___should_proceed=0
        # echo -e "[DEBUG]: found exact match? (1 means 'yes') ${publishing___should_proceed}"



        if [ $publishing___should_proceed -eq 1 ]; then
            echo -e  "\e[31m${VE_line_40}\e[0m"
            echo -e "\e[30;41mPUBLISHING SKIPPED\e[0;0m"
            echo -e  "\e[31m${VE_line_40}\e[0m"

            if [ "$publishing___should_dry_run" == 'yes' ]; then
                echo -e  "\e[30;41m[PSUEDO ACTION]\e[0;0m MOVE TO BACKUP FOLDER: \"\e[33m${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}\e[0m\""
            else
                echo -e  "\e[31mMOVE TO BACKUP FOLDER:\e[0m \"\e[33m${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}\e[0m\""
                mkdir -p "${publishing___tgz_cache_known_published_packages_folder_path}/${publishing___tgz_file_containing_folder_sub_path}"
                mv  -f  "${publishing___tgz_file_full_path}" "${publishing___tgz_cache_known_published_packages_folder_path}/${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}"
            fi
            echo -e  "\e[31m${VE_line_40}\e[0m"

            echo
            echo
            echo
            continue
        fi



        # echo -e  "\e[32m${VE_line_40}\e[0m"
        echo -e  "\e[30;42mPUBLISHING PACKAGE\e[0;0m ${publishing___package_full_name_with_version_colorful}"

        if [ "$publishing___should_dry_run" == 'yes' ]; then
            echo -e  "\e[31m${VE_line_40}\e[0m"
            echo -e  "\e[30;41m[PSUEDO ACTION]\e[0;0m npm publish --registry=\"${publishing___npm_registry_url}\" \"${publishing___tgz_file_full_path}\""
            echo -e  "\e[31m${VE_line_40}\e[0m"
        else
            echo -e  "\e[32m${VE_line_40}\e[0m"

            npm  publish  --registry="${publishing___npm_registry_url}"  "${publishing___tgz_file_full_path}"
            publishing___exitCodeOfPreviousCommand=$?

            if [ $publishing___exitCodeOfPreviousCommand -eq 0 ]; then
                echo -e  "\e[32m${VE_line_40}\e[0m"

                echo -e  "\e[33mMOVE TO BACKUP FOLDER:\e[0m \"\e[33m${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}\e[0m\""
                mkdir -p "${publishing___tgz_cache_known_published_packages_folder_path}/${publishing___tgz_file_containing_folder_sub_path}"
                mv  -f  "${publishing___tgz_file_full_path}" "${publishing___tgz_cache_known_published_packages_folder_path}/${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}"

                echo -e  "\e[32m${VE_line_40}\e[0m"
            else
                echo -e  "\e[31m${VE_line_40}\e[0m"

                echo -e  "\e[31mMOVE TO FAILED FOLDER:\e[0m \"\e[31m${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}\e[0m\""
                mkdir -p "${publishing___tgz_cache_known_packages_failed_to_publish_folder_path}/${publishing___tgz_file_containing_folder_sub_path}"
                mv  -f  "${publishing___tgz_file_full_path}" "${publishing___tgz_cache_known_packages_failed_to_publish_folder_path}/${publishing___tgz_file_containing_folder_sub_path}${publishing___tgz_file_name}"

                echo -e  "\e[31m${VE_line_40}\e[0m"
            fi
        fi

        echo
        echo
        echo
    done
}



for_all_cached_tgz_files_try_publish_them_to_a_registry \
    --tgz-cache-root-folder='' \
    --npm-registry-url='' \
    --should-dry-run='no' \
    --should-debug='no'



unset -f querying_an_npm_package_in_a_registry
unset -f for_all_cached_tgz_files_try_publish_them_to_a_registry
unset    VE_line_5
unset    VE_line_10
unset    VE_line_20
unset    VE_line_30
unset    VE_line_40
unset    VE_line_50
unset    VE_line_60
unset    VE_line_80
