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
  gha: "github",
};

const moveFileMap = {
  azdo: {},
  gha: {
    "build/github/aws/ci.env": ".github/workflows/ci.env",
    "build/github/aws/ci.yml": ".github/workflows/ci.yml",
  }
}

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
  } else if (!target.endsWith("/common")) {
    console.warn(`Unable to locate path "${target}"`);
  }
}

function cloneDeploymentFolder(dir, key) {
  clone(dir, key);
  clone(dir, "common");
}

function moveFiles(pipeline) {
  Object.keys(moveFileMap[pipeline]).forEach((source) => {
    const target = path.join(targetDir, source);
    const destination = path.join(targetDir, moveFileMap[pipeline][source]);

    if (fs.existsSync(target)) {
      if (!fs.existsSync(path.dirname(destination))) {
        fs.mkdirSync(path.dirname(destination), {
          recursive: true
        });
      }
      fs.renameSync(target, destination);
    } else {
      console.warn(`Unable to locate path "${target}"`);
    }
  });
}

cloneDeploymentFolder("build", pipelineMap[pipeline]);
cloneDeploymentFolder("deploy", platform);
cloneDeploymentFolder("docs", pipelineMap[pipeline]);
clone("taskctl.yaml");
moveFiles(pipeline);
