#!/usr/bin/env sh
##########################################
# DISABLE TELEMETRY.                     #
# https://github.com/beatcracker/toptout #
##########################################
# cspell:ignore TELE SERVICESETTINGS LOGSETTINGS ENABLEDIAGNOSTICS ENABLESECURITYFIXALERT DISABLETELEMETRY

# Helper Functions
run_cmd() {
    echo "+ $*"
    "$@"
}

is_command() {
    command -v "$1" >/dev/null 2>&1
}

# Disable telemetry.
# https://consoledonottrack.com/
#
# Dagger: https://dagger.io/
# Netdata: https://www.netdata.cloud
# Tilt: https://tilt.dev
export DO_NOT_TRACK=1

# Set adblock.
export ADBLOCK="true"

# Disable Microsoft Azure CLI telemetry.
# https://docs.microsoft.com/en-us/cli/azure
export AZURE_CORE_COLLECT_TELEMETRY=0

# Disable Serverless Application Model CLI AWS telemetry.
# https://aws.amazon.com/serverless/sam/
export SAM_CLI_TELEMETRY=0

# Disable Syncthing telemetry.
export STNOUPGRADE=1

# Yarn
# https://yarnpkg.com/
# https://yarnpkg.com/advanced/telemetry
export YARN_ENABLE_TELEMETRY=false

# Next.js
# https://nextjs.org
export NEXT_TELEMETRY_DISABLED=1

# Disable Gatsby telemetry.
export GATSBY_TELEMETRY_DISABLED=1

# Disable storybook telemetry.
export STORYBOOK_DISABLE_TELEMETRY=1

# .NET Core SDK
# https://docs.microsoft.com/en-us/dotnet/core/tools/index
# https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry#how-to-opt-out
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export DOTNET_EnableDiagnostics=0

# .NET Interactive
# https://github.com/dotnet/interactive
export DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT=1

# ML.NET CLI
# https://docs.microsoft.com/en-us/dotnet/machine-learning/automate-training-with-cli
export MLDOTNET_CLI_TELEMETRY_OPTOUT="True"

# dotnet-svcutil
# https://docs.microsoft.com/en-us/dotnet/core/additional-tools/dotnet-svcutil-guide
export DOTNET_SVCUTIL_TELEMETRY_OPTOUT=1

# Canvas LMS
# https://github.com/instructure/canvas-lms
# https://github.com/instructure/canvas-lms/blob/dc0e7b50e838fcca6f111082293b8faf415aff28/lib/tasks/db_load_data.rake#L154
export CANVAS_LMS_STATS_COLLECTION="opt_out"

# https://github.com/instructure/canvas-lms/blob/dc0e7b50e838fcca6f111082293b8faf415aff28/lib/tasks/db_load_data.rake#L16
export TELEMETRY_OPT_IN=""

# Eternal Terminal | Crash Data
# https://github.com/MisterTea/EternalTerminal
export ET_NO_TELEMETRY="ANY_VALUE"

# werf
# https://werf.io/
export WERF_TELEMETRY=0

# Nuke
# https://nuke.build/
export NUKE_TELEMETRY_OPTOUT=1

# MSLab
# https://github.com/microsoft/MSLab
export MSLAB_TELEMETRY_LEVEL="None"

# kPow
# https://kpow.io/
# https://docs.kpow.io/about/data-collection#how-do-i-opt-out
export ALLOW_UI_ANALYTICS="false"

# Earthly
# https://earthly.dev/
# https://github.com/earthly/earthly/blob/main/CHANGELOG.md#v0518---2021-07-08
export EARTHLY_DISABLE_ANALYTICS=1

# Stripe CLI
# https://stripe.com/docs/stripe-cli
export STRIPE_CLI_TELEMETRY_OPTOUT=1

# Feast
# https://feast.dev/
export FEAST_TELEMETRY="False"

# Meltano
# https://www.meltano.com/
export MELTANO_DISABLE_TRACKING="True"

# Quilt
# https://quiltdata.com/
export QUILT_DISABLE_USAGE_METRICS="True"

# Carbon Design System
# https://www.carbondesignsystem.com/
export CARBON_TELEMETRY_DISABLED=1

# Fastlane
# https://fastlane.tools/
export FASTLANE_OPT_OUT_USAGE="YES"

# Gatsby
# https://www.gatsbyjs.org
export GATSBY_TELEMETRY_DISABLED=1

# Oryx
# https://github.com/microsoft/Oryx
export ORYX_DISABLE_TELEMETRY="true"

# Rasa
# https://rasa.com/
export RASA_TELEMETRY_ENABLED="false"

# Google Cloud SDK
# https://cloud.google.com/sdk
export CLOUDSDK_CORE_DISABLE_USAGE_REPORTING="true"

# aliBuild
# https://github.com/alisw/alibuild
export ALIBUILD_NO_ANALYTICS=1

# Homebrew.
# https://brew.sh
# https://docs.brew.sh/Manpage#environment
export HOMEBREW_NO_ANALYTICS=1

# https://github.com/Homebrew/brew/blob/6ad92949e910041416d84a53966ec46b873e069f/Library/Homebrew/utils/analytics.sh#L38
export HOMEBREW_NO_ANALYTICS_THIS_RUN=1
export HOMEBREW_NO_AUTO_UPDATE=1

# decK
# https://github.com/Kong/deck
export DECK_ANALYTICS="off"

# Angular
# https://angular.io
# https://angular.io/analytics
# https://angular.io/cli/usage-analytics-gathering
export NG_CLI_ANALYTICS="false"
export NG_CLI_ANALYTICS_SHARE="false"

# InfluxDB
# https://www.influxdata.com/
# https://docs.influxdata.com/influxdb/v2.0/reference/config-options/
export INFLUXD_REPORTING_DISABLED="true"

# App Center CLI
# https://github.com/microsoft/appcenter-cli/
# https://github.com/microsoft/appcenter-cli/blob/master/src/util/profile/telemetry.ts
export MOBILE_CENTER_TELEMETRY="off"

# Arduino CLI
# https://arduino.github.io/arduino-cli/latest/
export ARDUINO_METRICS_ENABLED="false"

# PowerShell Core
# https://github.com/powershell/powershell
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_telemetry
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_update_notification
export POWERSHELL_TELEMETRY_OPTOUT=1
export POWERSHELL_UPDATECHECK="Off"

# LYNX VFX
# https://github.com/LucaScheller/VFX-LYNX
export LYNX_ANALYTICS=0

# Quickwit
# https://quickwit.io/
export DISABLE_QUICKWIT_TELEMETRY=1

# Automagica
# https://automagica.com/
export AUTOMAGICA_NO_TELEMETRY="1"

# Mattermost Server
# https://mattermost.com/
# https://docs.mattermost.com/manage/telemetry.html#error-and-diagnostics-reporting-feature
# https://docs.mattermost.com/manage/telemetry.html#security-update-check-feature
export MM_LOGSETTINGS_ENABLEDIAGNOSTICS="false"
export MM_SERVICESETTINGS_ENABLESECURITYFIXALERT="false"

# Appc Daemon
# https://github.com/appcelerator/appc-daemon
export APPCD_TELEMETRY=0

# Bot Framework CLI
# https://github.com/microsoft/botframework-cli
# https://github.com/microsoft/botframework-cli/tree/main/packages/cli#bf-configsettelemetry
export BF_CLI_TELEMETRY="false"

# Golang
# https://go.dev/
# https://github.com/golang/go/discussions/58409
export GOTELEMETRY="off"

# JavaScript debugger (VSCode)
# https://marketplace.visualstudio.com/items?itemName=ms-vscode.js-debug
# https://github.com/microsoft/vscode-js-debug/blob/12ec6df97f45b25b168e1eac8a17b802af73806f/src/ioc.ts#L168
export DA_TEST_DISABLE_TELEMETRY=1

# choosenim
# https://github.com/dom96/choosenim
export CHOOSENIM_NO_ANALYTICS=1

# CocoaPods
# https://cocoapods.org/
export COCOAPODS_DISABLE_STATS="true"

# Cube.js
# https://cube.dev/
# https://cube.dev/docs/reference/environment-variables#general
export CUBEJS_TELEMETRY="false"

# Hoockdeck CLI
# https://hookdeck.com/
# https://github.com/hookdeck/hookdeck-cli/blob/8c2e18bfd5d413e1d2418c5a73d56791b3bfb513/pkg/hookdeck/client.go#L56-L61
export HOOKDECK_CLI_TELEMETRY_OPTOUT=1

# VueDX
# https://github.com/znck/vue-developer-experience
export VUEDX_TELEMETRY="off"

# webhint
# https://webhint.io/
export HINT_TELEMETRY="off"

# Batect
# https://batect.dev/
export BATECT_ENABLE_TELEMETRY="false"

# Dagster
# https://dagster.io/
# https://github.com/dagster-io/dagster/blob/master/python_modules/dagit/dagit/telemetry.py
export DAGSTER_DISABLE_TELEMETRY=1

# Flagsmith API
# https://flagsmith.com/
export TELEMETRY_DISABLED=1

# PROSE Code Accelerator SDK
# https://www.microsoft.com/en-us/research/group/prose/
export PROSE_TELEMETRY_OPTOUT=1

# SKU
# https://github.com/seek-oss/sku
export SKU_TELEMETRY="false"

# Pants
# https://www.pantsbuild.org/
# https://www.pantsbuild.org/docs/reference-anonymous-telemetry
export PANTS_ANONYMOUS_TELEMETRY_ENABLED="false"

# Packer, Consul, Weave Net, WKSctl, Terraform, Cloud Development Kit for Terraform
# https://www.packer.io/
# https://www.weave.works/
# https://www.consul.io/
# https://www.consul.io/docs/agent/options#disable_update_check
# https://www.weave.works/oss/wksctl/
# https://www.terraform.io/
# https://github.com/hashicorp/terraform-cdk
# https://www.terraform.io/docs/commands/index.html#disable_checkpoint
export CHECKPOINT_DISABLE=1

# Terraform Provider for Azure
# https://registry.terraform.io/providers/hashicorp/azurerm/latest
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#disable_terraform_partner_id
export ARM_DISABLE_TERRAFORM_PARTNER_ID="true"

# Telepresence
# https://www.telepresence.io/
export SCOUT_DISABLE=1

# Pulumi
# https://www.pulumi.com/
export PULUMI_SKIP_UPDATE_CHECK="true"

# Kics
# https://kics.io/
# https://github.com/Checkmarx/kics/issues/3876
export DISABLE_CRASH_REPORT=1
export KICS_COLLECT_TELEMETRY=0

# Infracost
# https://www.infracost.io/
# https://www.infracost.io/docs/integrations/environment_variables/#infracost_self_hosted_telemetry
# https://www.infracost.io/docs/integrations/environment_variables/#infracost_skip_update_check
export INFRACOST_SELF_HOSTED_TELEMETRY="false"
export INFRACOST_SKIP_UPDATE_CHECK="true"

# AccessMap
# https://www.accessmap.io/
export ANALYTICS="no"

# Oh My Zsh
# https://ohmyz.sh/
export DISABLE_AUTO_UPDATE="true"

# Humbug
# https://github.com/bugout-dev/humbug
# https://github.com/bugout-dev/humbug/issues/13
export BUGGER_OFF=1

# Hasura GraphQL engine
# https://hasura.io
export HASURA_GRAPHQL_ENABLE_TELEMETRY="false"

# MeiliSearch
# https://github.com/meilisearch/MeiliSearch
export MEILI_NO_ANALYTICS="true"

# NocoDB
# https://www.nocodb.com/
export NC_DISABLE_TELE=1

# One Codex API - Python Client Library and CLI
# https://www.onecodex.com/
export ONE_CODEX_NO_TELEMETRY="True"

# Ory
# https://www.ory.sh/
export SQA_OPT_OUT="true"

# Rockset CLI
# https://rockset.com/
export ROCKSET_CLI_TELEMETRY_OPTOUT=1

# Tuist
# https://tuist.io/
export TUIST_STATS_OPT_OUT=1

# AutomatedLab
# https://github.com/AutomatedLab/AutomatedLab
export AUTOMATEDLAB_TELEMETRY_OPTIN=0
export AUTOMATEDLAB_TELEMETRY_OPTOUT=1

# Chef Workstation
# https://docs.chef.io/workstation/
# https://docs.chef.io/workstation/privacy/#opting-out
export CHEF_TELEMETRY_OPT_OUT=1

# kubeapt
# https://github.com/twosson/kubeapt
export DASH_DISABLE_TELEMETRY=1

# AutoSPInstaller Online
# https://github.com/IvanJosipovic/AutoSPInstallerOnline
# https://github.com/IvanJosipovic/AutoSPInstallerOnline/blob/3b4d0e3a7220632a00e36194ce540b8b34e9ed18/AutoSPInstaller.Core/Startup.cs#L36
export DisableTelemetry="True"

# PnP PowerShell
# https://pnp.github.io/powershell/
# https://pnp.github.io/powershell/articles/updatenotifications.html
# https://pnp.github.io/powershell/articles/configuration.html#disable-or-enable-telemetry
export PNPPOWERSHELL_DISABLETELEMETRY="true"
export PNPPOWERSHELL_UPDATECHECK="false"

# Salesforce CLI
# https://developer.salesforce.com/tools/sfdxcli
# https://github.com/forcedotcom/sfdx-core/blob/31fc950dd3fea9696d15e28ad944f07a08349e60/src/config/envVars.ts#L176-L179
export SF_DISABLE_TELEMETRY="true"

# Rover CLI
# https://www.apollographql.com/docs/rover/
export APOLLO_TELEMETRY_DISABLED=1

# ReportPortal (JS client)
# https://github.com/reportportal/client-javascript
export REPORTPORTAL_CLIENT_JS_NO_ANALYTICS="true"

# Salto CLI
# https://www.salto.io/
export SALTO_TELEMETRY_DISABLE=1

# vstest
# https://github.com/microsoft/vstest/
# https://github.com/microsoft/vstest/blob/main/src/vstest.console/TestPlatformHelpers/TestRequestManager.cs#L1047
export VSTEST_TELEMETRY_OPTEDIN=0

# Nuxt.js
# https://nuxtjs.org/
export NUXT_TELEMETRY_DISABLED=1

# mssql-cli
# https://github.com/dbcli/mssql-cli
export MSSQL_CLI_TELEMETRY_OPTOUT="True"

# Vagrant
# https://www.vagrantup.com/
# https://www.vagrantup.com/docs/other/environmental-variables#vagrant_checkpoint_disable
# https://www.vagrantup.com/docs/other/environmental-variables#vagrant_box_update_check_disable
export VAGRANT_CHECKPOINT_DISABLE=1
export VAGRANT_BOX_UPDATE_CHECK_DISABLE=1

# Salesforce CLI
# https://developer.salesforce.com/tools/sfdxcli
export SFDX_DISABLE_TELEMETRY="true"

# RESTler
# https://github.com/microsoft/restler-fuzzer
# https://github.com/microsoft/restler-fuzzer/blob/main/docs/user-guide/Telemetry.md
export RESTLER_TELEMETRY_OPTOUT=1

# F5 BIG-IP Terraform provider
# https://registry.terraform.io/providers/F5Networks/bigip/latest/docs
export TEEM_DISABLE="true"

# F5 CLI
# https://clouddocs.f5.com/sdk/f5-cli/
export F5_ALLOW_TELEMETRY="false"

# Apache Cordova CLI
# https://cordova.apache.org
# export CI=1

# Webiny
# https://www.webiny.com/
# https://github.com/webiny/webiny-js/blob/0240c2000d1743160c601ae4ce40dd2f949d4d07/packages/telemetry/react.js#L9
export REACT_APP_WEBINY_TELEMETRY="false"

# Strapi
# https://strapi.io/
# https://strapi.io/documentation/developer-docs/latest/setup-deployment-guides/configurations.html#environment
export STRAPI_TELEMETRY_DISABLED="true"
export STRAPI_DISABLE_UPDATE_NOTIFICATION="true"

# Serverless Framework
# https://www.serverless.com/
# https://github.com/serverless/serverless/blob/18d4d69eb3b1220814ab031690b6ef899280a93a/lib/utils/telemetry/are-disabled.js#L5-L9
export SLS_TRACKING_DISABLED=1
export SLS_TELEMETRY_DISABLED=1

# Prisma
# https://www.prisma.io/
# https://www.prisma.io/docs/concepts/more/telemetry#usage-data
export CHECKPOINT_DISABLE=1

# projector-cli
# https://github.com/projector-cli/projector-cli
export TELEMETRY_ENABLED=0

# Testim Root Cause
# https://github.com/testimio/root-cause
export SUGGESTIONS_OPT_OUT=1

# TYPO3
# https://github.com/instructure/canvas-lms
# https://docs.typo3.org/m/typo3/guide-installation/master/en-us/Legacy/Index.html#disabling-the-core-updater
# https://forge.typo3.org/issues/53188
export TYPO3_DISABLE_CORE_UPDATER=1
export REDIRECT_TYPO3_DISABLE_CORE_UPDATER=1

# Firefox
# https://www.mozilla.org/firefox/
# https://github.com/mozilla/policy-templates/blob/master/README.md
# https://github.com/mozilla/policy-templates/tree/master/mac
case "$(uname -s)" in Darwin*)
    if is_command firefox defaults; then
        run_cmd "defaults" "write /Library/Preferences/org.mozilla.firefox EnterprisePoliciesEnabled -bool TRUE"
        run_cmd "defaults" "write /Library/Preferences/org.mozilla.firefox DisableTelemetry -bool TRUE"
    fi
    ;;
*) ;;
esac

# ImageGear
# https://www.accusoft.com/products/imagegear-collection/imagegear/
# https://help.accusoft.com/ImageGear/v18.8/Linux/Installation.html
case "$(uname -s)" in Linux*)
    export IG_PRO_OPT_OUT="YES"
    ;;
*) ;;
esac

# Netlify CLI
# https://netlify.com
if is_command netlify; then
    run_cmd "netlify" "--telemetry-disable"
fi

# WAPM CLI
# https://wasmer.io/
if is_command wapm; then
    run_cmd "wapm" "config set telemetry.enabled false"
fi

# TimescaleDB
# https://www.timescale.com/
if is_command psql; then
    run_cmd "psql" "-c ALTER SYSTEM SET timescaledb.telemetry_level=off"
fi

# DVC
# https://dvc.org/
if is_command dvc; then
    run_cmd "dvc" "config core.analytics false --global"
fi

# Microsoft Power Platform CLI
# https://docs.microsoft.com/en-us/powerapps/developer/data-platform/powerapps-cli
if is_command pac; then
    run_cmd "pac" "telemetry disable"
fi

# Skaffold
# https://skaffold.dev/
if is_command skaffold; then
    run_cmd "skaffold" "config set --global collect-metrics false"
fi

# AWS Amplify CLI
# https://aws.amazon.com/amplify/
if is_command amplify; then
    run_cmd "amplify" "configure --usage-data-off"
fi

# App Center CLI
# https://github.com/microsoft/appcenter-cli/
if is_command appcenter; then
    run_cmd "appcenter" "telemetry off"
fi

# Scaleway CLI (v2)
# https://www.scaleway.com/en/cli/
if is_command scw; then
    run_cmd "scw" "config set send-telemetry=false"
fi

# Azure Service Fabric CLI
# https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-sfctl
if is_command sfctl; then
    run_cmd "sfctl" "settings telemetry set_telemetry --off"
fi

# Ionic CLI
# https://ionicframework.com/
if is_command ionic; then
    run_cmd "ionic" "config set --global telemetry false"
fi

# Capacitor
# https://capacitorjs.com
if is_command cap nx; then
    run_cmd "nx" "cap telemetry off"
fi

# Webiny
# https://www.webiny.com/
# https://www.webiny.com/docs/key-topics/webiny-cli/#yarn-webiny-disable-tracking
if is_command webiny yarn; then
    run_cmd "yarn" "webiny disable-tracking"
fi

# Aerospike
# https://aerospike.com/
if is_command /opt/aerospike/telemetry/telemetry.py; then
    run_cmd "/opt/aerospike/telemetry/telemetry.py" "/etc/aerospike/telemetry.conf --disable"
fi

# Flutter
# https://flutter.dev/
if is_command flutter; then
    run_cmd "flutter" "config --no-analytics"
fi

# Microsoft 365 | Enterprise
# https://www.microsoft.com/en-us/microsoft-365/enterprise
# https://docs.microsoft.com/en-us/deployoffice/privacy/overview-privacy-controls#diagnostic-data-sent-from-microsoft-365-apps-for-enterprise-to-microsoftd
case "$(uname -s)" in Darwin*)
    if is_command winword defaults; then
        run_cmd "defaults" "write com.microsoft.office DiagnosticDataTypePreference -string ZeroDiagnosticData"
    fi
    ;;
*) ;;
esac
