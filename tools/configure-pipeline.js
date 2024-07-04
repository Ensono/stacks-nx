#! /usr/bin/env node

const { parseArgs } = require("node:util");
const fs = require("fs");
const path = require("path");

const argOptions = {
  tmpDir: { type: "string", required: true },
  targetDir: { type: "string", required: true },
  pipeline: { type: "string", required: true },
  platform: { type: "string", required: true },
};

const pipelineMap = {
  azdo: "azDevOps",
};

const { values } = parseArgs({
  options: argOptions,
});

Object.keys(argOptions).forEach((key) => {
  if (!values[key]) {
    throw new Error(`Missing arg for --${key}=`);
  }
});

const { tmpDir, targetDir, pipeline, platform } = values;

function cloneFolderByKey(path, key) {
  const target = path.join(tmpDir, path, key);
  const destination = path.join(targetDir, path, key);

  if (fs.existsSync(target)) {
    fs.cpSync(target, destination, { force: true, recursive: true });
  } else if (key !== "common") {
    console.warn(`Unable to locate path "${path}" with key "${key}"`);
  }
}

function cloneDeploymentFolder(path, key) {
  cloneFolderByKey(path, key);
  cloneFolderByKey(path, "common");
}

cloneDeploymentFolder("build", pipelineMap[pipeline]);
cloneDeploymentFolder("deploy", platform);
cloneDeploymentFolder("docs", pipelineMap[pipeline]);
