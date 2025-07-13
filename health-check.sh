#!/bin/bash

set -e

GREEN="\\033[1;32m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"
RESET="\\033[0m"

REQUIRED_TOOLS=(docker curl mysqladmin redis-cli)

# 🔍 Check and install missing tools
check_and_install_tools() {
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &>/dev/null; then
      echo -e "${BLUE}⚙️  Installing missing tool: $tool${RESET}"
      sudo apt-get update && sudo apt-get install -y $tool
    else
      echo -e "${GREEN}✔️  $tool is installed${RESET}"
    fi
  done
}

# 🩺 Service Health Check Function
check_service() {
  local name="$1"
  local cmd="$2"
  echo -n "🔧 Checking $name... "
  if eval "$cmd" > /dev/null 2>&1; then
    echo -e "${GREEN}UP${RESET}"
  else
    echo -e "${RED}DOWN${RESET}"
  fi
}

# 🚀 Run all checks
run_checks() {
  echo -e "${BLUE}🔍 Running Magento Docker Stack Health Check...${RESET}"

  # MySQL container health
  check_service "MySQL" "docker exec mysql mysqladmin ping -uroot -proot"

  # Redis container health
  check_service "Redis" "docker exec redis redis-cli ping | grep PONG"

  # Elasticsearch health
  check_service "Elasticsearch" "curl -s http://localhost:9200 | grep 'cluster_name'"

  # Magento App (HTTP 200)
  check_service "Magento App URL" "curl -s -o /dev/null -w \"%{http_code}\" http://localhost | grep 200"

  # PHPMyAdmin (HTTP 200)
  check_service "PHPMyAdmin URL" "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:8080 | grep 200"

  echo -e "${GREEN}✅ Health check complete.${RESET}"
}

# 🧙 Run everything
check_and_install_tools
run_checks