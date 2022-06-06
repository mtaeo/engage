import GameStatsPieChart from "./pie_chart";

let Hooks = {};

Hooks.GameStatsPieChart = {
  mounted() {
    const { labels, values } = JSON.parse(this.el.dataset.chartData);
    this.chart = new GameStatsPieChart(this.el, labels, values);
  },
};

export default Hooks;
