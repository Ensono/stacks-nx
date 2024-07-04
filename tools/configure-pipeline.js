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

function clone(...fragments) {
  const target = path.join(tmpDir, ...fragments);
  const destination = path.join(targetDir, ...fragments);

  if (fs.existsSync(target)) {
    fs.cpSync(target, destination, {
      force: true,
      recursive: true,
    });
  } else if (key !== "common") {
    console.warn(`Unable to locate path "${target}"`);
  }
}

function cloneDeploymentFolder(...fragments) {
  clone(...fragments);
  clone(...fragments, "common");
}

cloneDeploymentFolder("build", pipelineMap[pipeline]);
cloneDeploymentFolder("deploy", platform);
cloneDeploymentFolder("docs", pipelineMap[pipeline]);
clone("taskctl.yaml");
