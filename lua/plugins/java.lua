-- Java support via nvim-jdtls (https://github.com/mfussenegger/nvim-jdtls)
--
-- Requirements: a JDK 21+ on PATH (or JAVA_HOME) to run jdtls, and python3 for Mason's jdtls launcher.
-- Mason installs jdtls, java-debug-adapter and java-test (see lsp.lua). Your projects can target
-- any Java version; register extra JDKs below under `runtimes` if you need to switch between them.
--
-- Supports Maven, Gradle and plain projects, Lombok, debugging (<F5>) and running JUnit tests.
vim.pack.add { gh 'mfussenegger/nvim-jdtls' }

local function mason_path(rel) return vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', rel) end

---Bundles add debugging and test running to jdtls
local function bundles()
  local jars = vim.fn.glob(mason_path 'java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
  for _, jar in ipairs(vim.fn.glob(mason_path 'java-test/extension/server/*.jar', true, true)) do
    local name = vim.fs.basename(jar)
    -- These two jars are not OSGi bundles and break jdtls when loaded
    if name ~= 'com.microsoft.java.test.runner-jar-with-dependencies.jar' and name ~= 'jacocoagent.jar' then table.insert(jars, jar) end
  end
  return jars
end

-- Groups are tried in order, each one all the way up the tree. This makes multi-module projects use
-- their top-level directory: a module's own pom.xml/build.gradle must not win, or jdtls only imports
-- that module and `gd` into sibling modules finds nothing.
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
          -- Register additional JDKs here, e.g.:
          -- runtimes = {
          --   { name = 'JavaSE-17', path = '/usr/lib/jvm/java-17-openjdk' },
          --   { name = 'JavaSE-21', path = '/usr/lib/jvm/java-21-openjdk', default = true },
          -- },
        },
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
  end,
})
