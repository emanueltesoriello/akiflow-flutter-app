class IntegrationsUtils {
  static String titleFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return "Asana";
      case "clickup":
        return "ClickUp";
      case "dropbox":
        return "Dropbox";
      case "google":
        return "Google Calendar";
      case "gmail":
        return "Gmail";
      case "github":
        return "GitHub";
      case "jira":
        return "Jira";
      case "skype":
        return "Skype";
      case "teams":
        return "Teams";
      case "notion":
        return "Notion";
      case "slack":
        return "Slack";
      case "superhuman":
        return "Superhuman";
      case "todoist":
        return "Todoist";
      case "trello":
        return "Trello";
      case "twitter":
        return "Twitter";
      case "zapier":
        return "Zapier";
      case "zoom":
        return "Zoom";
      default:
        return connectorId ?? "";
    }
  }

  static String howToLinkFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return "https://www.notion.so/akiflow/Asana-5822803b3a7b48439d4f66721168ffce?pvs=4";
      case "clickup":
        return "https://www.notion.so/akiflow/ClickUp-8ce3e4e6b0424a50b4253f6e75d7c37c?pvs=4";
      case "google":
        return "https://www.notion.so/akiflow/Google-Calendar-11ac44b0584a4ecbb72a588c5b00ed9f?pvs=4";
      case "gmail":
        return "https://www.notion.so/akiflow/Gmail-Superhuman-4589570afd764286a8b366ebb4e064e9?pvs=4";
      case "github":
        return "https://www.notion.so/akiflow/GitHub-e33a89816e644c15a3bec8c4ed6c79b8?pvs=4";
      case "jira":
        return "https://www.notion.so/akiflow/Jira-7830c9a843c44e73aa333ce74c622f36?pvs=4";
      case "notion":
        return "https://www.notion.so/akiflow/Notion-92be27499eea4fd4bb8f575a9c69f507?pvs=4";
      case "slack":
        return "https://www.notion.so/akiflow/Slack-c3fe4e22e869483e8177b72a4cf777ca?pvs=4";
      case "todoist":
        return "https://www.notion.so/akiflow/Todoist-c55615de0ae44c50be9bbae07e7a8caa?pvs=4";
      case "trello":
        return "https://www.notion.so/akiflow/Trello-daa16f3687f749b19e3edf5e724fa8a0?pvs=4";
      case "zapier":
        return "https://www.notion.so/akiflow/Zapier-c94fbcc11c204488b1e1502eb59639ce?pvs=4";
      case "zoom":
        return "https://www.notion.so/akiflow/Zoom-59eeec3e58084f30b17893bd0641f5de?pvs=4";
      default:
        return connectorId ?? "";
    }
  }
}
