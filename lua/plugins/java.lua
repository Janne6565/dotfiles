-- Java support via nvim-jdtls (https://github.com/mfussenegger/nvim-jdtls)
--
-- Requirements: a JDK 21+ on PATH (or JAVA_HOME) to run jdtls, and python3 for Mason's jdtls launcher.
-- Mason installs jdtls, java-debug-adapter and java-test (see lsp.lua). Your projects can target
-- any Java version: installed JDKs (SDKMAN, /usr/lib/jvm, macOS) are detected and registered automatically.
--
-- Supports Maven, Gradle and plain projects, Lombok, debugging (<F5>) and running JUnit tests.
vim.pack.add { gh 'mfussenegger/nvim-jdtls' }

local function mason_path(rel) return vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', rel) end

---Bundles add debugging and test running to jdtls
local function bundles()
  local jars = vim.fn.glob(mason_path 'java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
  for _, jar in ipairs(vim.fn.glob(mason_path 'java-test/extension/server/*.jar', true, true)) do
    local name = vim.fs.basename(jar)
    -- The runner and jacoco jars are not OSGi bundles, and jdtls already ships its own asm bundles
    local skip = name == 'com.microsoft.java.test.runner-jar-with-dependencies.jar' or name == 'jacocoagent.jar' or name:match '^org%.objectweb%.asm'
    if not skip then table.insert(jars, jar) end
  end
  return jars
end

-- Groups are tried in order, each one all the way up the tree. This makes multi-module projects use
-- their top-level directory: a module's own pom.xml/build.gradle must not win, or jdtls only imports
-- that module and `gd` into sibling modules finds nothing.
-- Installed JDKs by major version, read from each JDK's `release` file
---@return table<integer, string>
local function find_jdks()
  local jdks = {}
  local patterns = {
    '~/.sdkman/candidates/java/*',
    '/usr/lib/jvm/*',
    '/Library/Java/JavaVirtualMachines/*/Contents/Home',
    '~/Library/Java/JavaVirtualMachines/*/Contents/Home',
  }
  for _, pattern in ipairs(patterns) do
    for _, dir in ipairs(vim.fn.glob(pattern, true, true)) do
      local release = vim.fs.joinpath(dir, 'release')
      if vim.uv.fs_stat(release) then
        local version = table.concat(vim.fn.readfile(release), '\n'):match 'JAVA_VERSION="([%d.]+)'
        local major = version and tonumber(version:match '^1%.(%d+)' or version:match '^(%d+)')
        local path = vim.uv.fs_realpath(dir)
        if major and path and not jdks[major] then jdks[major] = path end
      end
    end
  end
  return jdks
end

local jdks = find_jdks()

-- jdtls runs the Gradle import on its own JVM by default. Old Gradle versions cannot run on new Java
-- (Gradle 8.x does not support Java 25), the import fails and every file becomes a "non-project file".
-- Prefer an LTS JDK that Gradle 8 supports. Override with the JDTLS_GRADLE_JAVA_HOME environment variable.
local gradle_java_home = vim.env.JDTLS_GRADLE_JAVA_HOME or jdks[21] or jdks[17]

local runtimes = {}
for major, path in pairs(jdks) do
  table.insert(runtimes, { name = major <= 8 and ('JavaSE-1.' .. major) or ('JavaSE-' .. major), path = path })
end
table.sort(runtimes, function(a, b) return a.path < b.path end)

local root_markers = {
  { 'mvnw', 'gradlew', 'settings.gradle', 'settings.gradle.kts' }, -- build root
  { '.git' }, -- repository root
  { 'pom.xml', 'build.gradle', 'build.gradle.kts' }, -- single project without wrapper or git
}

local function start_jdtls()
  local jdtls = require 'jdtls'
  local root_dir = vim.fs.root(0, root_markers) or vim.fn.getcwd()
  -- jdtls keeps per-project index data here; delete it if a project gets into a weird state
  local workspace = vim.fs.joinpath(vim.fn.stdpath 'cache', 'jdtls', vim.fn.fnamemodify(root_dir, ':p:h:gs?/?%?'))

  local cmd = { 'jdtls', '-data', workspace }
  local lombok = mason_path 'jdtls/lombok.jar'
  if vim.uv.fs_stat(lombok) then table.insert(cmd, 2, '--jvm-arg=-javaagent:' .. lombok) end

  jdtls.start_or_attach {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    init_options = { bundles = bundles() },
    -- nvim-jdtls registers the Java debug adapter and discovers main classes on <F5> by itself
    dap = { hotcodereplace = 'auto' },
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = {
          updateBuildConfiguration = 'interactive',
          runtimes = runtimes, -- JDKs a project can compile against (matched to its sourceCompatibility/toolchain)
        },
        import = { gradle = { java = { home = gradle_java_home } } },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = 'literals' } },
        signatureHelp = { enabled = true },
        format = { enabled = true },
        saveActions = { organizeImports = false },
        completion = {
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.Assert.*',
            'org.mockito.Mockito.*',
            'org.mockito.ArgumentMatchers.*',
            'org.hamcrest.Matchers.*',
            'org.assertj.core.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
          },
          importOrder = { 'java', 'javax', 'jakarta', 'org', 'com', '' },
        },
        sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
        codeGeneration = {
          toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
          useBlocks = true,
        },
      },
    },
  }
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user-java', { clear = true }),
  pattern = 'java',
  callback = function(ev)
    start_jdtls()

    local jdtls = require 'jdtls'
    local function map(mode, keys, fn, desc) vim.keymap.set(mode, keys, fn, { buffer = ev.buf, desc = 'Java: ' .. desc }) end
    map('n', '<leader>jo', jdtls.organize_imports, 'Organize imports')
    map({ 'n', 'x' }, '<leader>jv', function() jdtls.extract_variable(vim.fn.mode() ~= 'n') end, 'Extract variable')
    map({ 'n', 'x' }, '<leader>jV', function() jdtls.extract_variable_all(vim.fn.mode() ~= 'n') end, 'Extract variable (all occurrences)')
    map({ 'n', 'x' }, '<leader>jc', function() jdtls.extract_constant(vim.fn.mode() ~= 'n') end, 'Extract constant')
    map('x', '<leader>jm', function() jdtls.extract_method(true) end, 'Extract method')
    map('n', '<leader>jt', jdtls.test_nearest_method, 'Test nearest method')
    map('n', '<leader>jT', jdtls.test_class, 'Test class')
    map('n', '<leader>jp', function() require('jdtls.tests').goto_subjects() end, 'Jump between test and subject')
    map('n', '<leader>jg', function() require('jdtls.tests').generate() end, 'Generate tests')
    map('n', '<leader>ju', '<cmd>JdtUpdateConfig<CR>', 'Reload project config (pom/gradle)')
    map('n', '<leader>jb', '<cmd>JdtCompile full<CR>', 'Full build')
    map('n', '<leader>jw', '<cmd>JdtWipeDataAndRestart<CR>', 'Wipe workspace data and restart')
    map('n', '<leader>jR', '<cmd>JavaReport<CR>', 'jdtls report (troubleshooting)')
  end,
})

-- :JavaReport opens a scratch buffer with jdtls' project root, workspace, log errors and diagnostics.
-- Use it when goto-definition/completion stop working to see whether the project import failed.
vim.api.nvim_create_user_command('JavaReport', function()
  local lines = {}
  local function add(s) vim.list_extend(lines, vim.split(s, '\n')) end
  local c = vim.lsp.get_clients({ bufnr = 0, name = 'jdtls' })[1]
  add('file: ' .. vim.api.nvim_buf_get_name(0))
  add('jdtls attached: ' .. tostring(c ~= nil))
  if c then
    add('root_dir: ' .. tostring(c.root_dir))
    local data = c.config.cmd[vim.fn.index(c.config.cmd, '-data') + 2]
    add('workspace: ' .. tostring(data))
    add(
      'build files in root: '
        .. table.concat(
          vim.fn.globpath(c.root_dir, '{pom.xml,build.gradle,build.gradle.kts,settings.gradle,settings.gradle.kts,mvnw,gradlew}', false, true),
          ', '
        )
    )
    local props = c.root_dir .. '/gradle/wrapper/gradle-wrapper.properties'
    if vim.uv.fs_stat(props) then add('gradle wrapper: ' .. (vim.fn.readfile(props)[vim.fn.match(vim.fn.readfile(props), 'distributionUrl') + 1] or '?')) end
    local log = data and (data .. '/.metadata/.log')
    if log and vim.uv.fs_stat(log) then
      local all = vim.fn.readfile(log)
      local errs = vim.tbl_filter(function(l) return l:match '^!MESSAGE' or l:match 'Exception' or l:match 'rror' end, all)
      add('--- last errors in jdtls log (' .. log .. '):')
      for i = math.max(1, #errs - 25), #errs do
        add(errs[i] or '')
      end
    end
  end
  add('java on PATH: ' .. vim.trim(vim.fn.system 'java -version 2>&1 | head -1'))
  add('detected JDKs: ' .. table.concat(vim.tbl_map(function(r) return r.name .. '=' .. r.path end, runtimes), ', '))
  add('JDK used for Gradle import: ' .. tostring(gradle_java_home or 'none found, jdtls JVM (java on PATH)'))
  add('JAVA_HOME: ' .. tostring(vim.env.JAVA_HOME))
  add '--- diagnostics in this buffer:'
  for _, d in ipairs(vim.diagnostic.get(0)) do
    add(('%d: %s'):format(d.lnum + 1, d.message))
  end
  add '--- recent notifications:'
  local ok, hist = pcall(function() return Snacks.notifier.get_history() end)
  for _, n in ipairs(ok and hist or {}) do
    add(n.msg)
  end
  vim.cmd 'new'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype, vim.bo.bufhidden = 'nofile', 'wipe'
end, { desc = 'Show jdtls diagnostics report' })
