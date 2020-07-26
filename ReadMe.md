# 批量发布 npm 包至特定注册点的工具

## 简介

我们可以借助 [verdaccio](https://verdaccio.org/) 这样的工具搭建私有 npm 注册点服务器，简称私有 npm 服务器。

但要方便的将大批 npm 包的 `.tgz` 文件导入我们的私有 npm 服务器则没有现成工具。本人遂构建本工具，以较为方便的将已经在本机的某些 node_modules 文件夹内的 npm 包，批量【发布】（`publish`）到我们的私有 npm 服务器上。

本工具是一个 bash 脚本，内部调用 `npm  publish  "文件夹路径"` 命令来发布 npm 包至指定 npm 服务器。默认的 npm 服务器为 verdaccio 搭建的 `http://localhost:4873`。

---

## 用法

### 语法

```bash
source  "<本工具路径>/source/search-a-folder-and-publish-all.sh"  ["<深度搜索所有node_modules文件夹的起始文件夹路径>"]  ["<注册点服务器的URL>"]
```

### 示例

假定该工具存放在 `/d/tools` 文件夹中。

- 从当前文件夹开始深度搜索：

    ```bash
    source  "/d/tools/wulechuan-bash-publish-npm-packages-in-batch/source/search-a-folder-and-publish-all.sh"
    ```

- 从指定文件夹（`/c/Users/wulechuan/AppData/Roaming/npm/`）开始深度搜索：

    ```bash
    source  "/d/tools/wulechuan-bash-publish-npm-packages-in-batch/source/search-a-folder-and-publish-all.sh"  "/c/Users/wulechuan/AppData/Roaming/npm/"
    ```

- 发布到指定的注册点：

    ```bash
    source  "/d/tools/wulechuan-bash-publish-npm-packages-in-batch/source/search-a-folder-and-publish-all.sh"  .  "https://registry.npmjs.com"
    ```

---

## 已知问题

### 问题列表

- [x] 【已解决】 在一个 npm 包文件夹中，借助 `npm  publish` 来发布该包时，如果发布的目标注册点服务器不是官方默认的 `https://registry.npmjs.com`，那么，某些包的过程是会遭遇错误的。例如，有些 npm 包配置了所谓 `prepublish` 任务脚本，这些脚本往往依赖多个 `devDependencies`，而如果不获取该包对应的源代码，那么这些 `devDependencies` 不会被下载，故而这些 npm 包无法在我们本机发布。

- [x] 【已解决】 另外，即便发布过程中没有技术性错误，也可能遇到版本不正确的问题。这是因为，有些 npm 包的发布配置中包含了“自动令版本号增加”的逻辑。因此，该 npm 包从我们本机发布时，发布的版本或许并不正确。

<!-- ### 解决问题的思路探索

可能要放弃深度扫描 `node_modules` 文件夹的做法。看看是否有途径（例如网页爬虫）直接大批量获取 `.tgz` 文件。然后修订本工具，改为批量发布这些 `.tgz` 文件。 -->
