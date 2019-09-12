<template>
  <v-container>
    <v-card>
      <v-card-title>Type any word</v-card-title>
      <v-container>
        <v-row>
          <v-col cols="10">
            <v-text-field
              v-model="search"
              placeholder="e.g. broadcast, gay, mug, ..."
              outlined
              @change="getVectors()"
              :hide-details="true"
            ></v-text-field>
          </v-col>
          <v-col>
            <v-select :items="embeddings" v-model="embedding" :hide-details="true"></v-select>
          </v-col>
        </v-row>
        <v-row align="center" justify="center" v-if="data.vectors.length > 0">
          <v-col cols="12">
            <svg width="100%">
              <defs>
                <marker
                  id="head"
                  orient="auto"
                  markerWidth="2"
                  markerHeight="4"
                  refX="0.1"
                  refY="2"
                >
                  <path d="M0,0 V4 L2,2 Z" fill="gray" />
                </marker>
              </defs>
            </svg>
          </v-col>
        </v-row>
      </v-container>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import * as d3 from "d3";
import { vec, coord } from "../types/vec";
import { range } from "lodash";

const dotSize = 5;
let width = 800,
  height = 500;

@Component({})
export default class Main extends Vue {
  search = "";
  lastSearch = "";
  data: { vectors: vec[] } = { vectors: [] };

  border = 30;
  dotSize = dotSize;
  arrowSize = this.dotSize / 2;

  embeddings = [
    {
      text: "English (All)",
      value: "eng-all_sgns"
    },
    {
      text: "English (Fiction)",
      value: "eng-fiction-all_sgns"
    },
    {
      text: "German",
      value: "ger-all_sgns"
    }
  ];
  embedding = this.embeddings[0].value;

  sX: d3.ScaleLinear<number, number> = d3
    .scaleLinear()
    .domain([0, 0])
    .range([0, 0]);
  sY: d3.ScaleLinear<number, number> = d3
    .scaleLinear()
    .domain([0, 0])
    .range([0, 0]);

  getVectors(): void {
    this.lastSearch = this.search;
    fetch(
      `http://127.0.0.1:8000/vec/?word=${this.lastSearch}&embedding=${this.embedding}`
    )
      .then(response => response.json())
      .then(data => (this.data = data))
      .then(() => this.draw())
      .catch(error => console.log(error));
  }

  draw(): void {
    const svg = d3.select("svg");
    svg.selectAll("svg > circle, line").remove();

    const w = svg.style("width");
    const h = svg.style("height");
    width = +w.substr(0, w.length - 2) - this.border / 2;
    height = +h.substr(0, h.length - 2) - this.border / 2;

    this.sX = d3
      .scaleLinear()
      .domain(this.domain.x)
      .range([0, width - this.border]);
    this.sY = d3
      .scaleLinear()
      .domain(this.domain.y)
      .range([0, height - this.border]);

    this.data.vectors = this.data.vectors.map((v, i) => ({
      pos: {
        x: this.sX(v.pos.x) + this.border / 2,
        y: this.sY(v.pos.y) + this.border / 2
      },
      word: v.word,
      year: v.year,
      closest: this.findClosest(i).word
    }));

    const lines = svg.selectAll("line").data(this.lines);
    lines
      .enter()
      .append("line")
      .attr("x1", d => d[0].x)
      .attr("y1", d => d[0].y)
      .attr("x2", d => this.adjustLine(d[0], d[1]).x)
      .attr("y2", d => this.adjustLine(d[0], d[1]).y)
      .attr("marker-end", "url(#head)")
      .style("stroke-width", this.arrowSize)
      .style("stroke", "gray");
    lines.exit().remove();

    const circles = svg.selectAll("circle").data(this.data.vectors);
    circles
      .enter()
      .append("circle")
      .attr("cx", d => d.pos.x)
      .attr("cy", d => d.pos.y)
      .attr("r", this.dotSize)
      .style("fill", "indianred")
      .on("mouseover", mouseOver)
      .on("mouseout", mouseOut)
      .filter(d => d.word === this.lastSearch)
      .style("fill", "steelblue")
      .filter((d, i) => i === 0)
      .style("fill", "#DAF7A6");
    circles.exit().remove();
  }

  get domain(): { x: [number, number]; y: [number, number] } {
    const xs = this.data.vectors.map(v => v.pos.x);
    const ys = this.data.vectors.map(v => v.pos.y);
    const minX = Math.min(...xs);
    const minY = Math.min(...ys);
    const maxX = Math.max(...xs);
    const maxY = Math.max(...ys);
    return {
      x: [minX, maxX],
      y: [minY, maxY]
    };
  }

  get lines(): coord[][] {
    const coords = this.data.vectors
      .filter(v => v.word === this.lastSearch)
      .sort((a, b) => a.year - b.year)
      .map(v => v.pos);
    return range(0, coords.length - 1).map(i => [coords[i], coords[i + 1]]);
  }

  adjustLine(a: coord, b: coord): coord {
    const d = Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
    const d2 = d - this.dotSize * 1.5;
    const ratio = d2 / d;
    const dx = (b.x - a.x) * ratio;
    const dy = (b.y - a.y) * ratio;
    return {
      x: a.x + dx,
      y: a.y + dy
    };
  }

  findClosest(i: number): vec {
    const v = this.data.vectors[i];
    return this.data.vectors
      .filter(w => w.word !== v.word)
      .filter((w, j) => j !== i)
      .map(w => ({ w, d: this.distance(v, w) }))
      .sort((a, b) => a.d - b.d)[0].w;
  }

  distance(a: vec, b: vec): number {
    return Math.sqrt(
      Math.pow(b.pos.x - a.pos.x, 2) + Math.pow(b.pos.y - a.pos.y, 2)
    );
  }
}

function mouseOver(d: vec, i: number): boolean {
  const boxWidth = 150;
  const boxHeight = 78;
  const boxX = Math.min(width - boxWidth, Math.max(0, d.pos.x - boxWidth / 2));
  const boxY =
    d.pos.y < boxHeight * 1.5
      ? d.pos.y + dotSize * 3
      : d.pos.y - boxHeight - dotSize * 3;

  d3.select(this).attr("r", dotSize * 2);
  const box = d3
    .select("svg")
    .append("g")
    .attr("id", "box");
  box
    .append("rect")
    .attr("x", boxX)
    .attr("y", boxY)
    .attr("width", boxWidth)
    .attr("height", boxHeight)
    .style("fill", "white")
    .style("stroke", "gray")
    .style("stroke-width", 1);
  box
    .append("text")
    .attr("x", boxX + 16)
    .attr("y", boxY + 32)
    .attr("class", "body-1 font-weight-light")
    .text(d.word);
  box
    .append("text")
    .attr("x", boxX + 16)
    .attr("y", boxY + 32 + 16 + 2)
    .attr("class", "overline")
    .text(d.year);
  box
    .append("text")
    .attr("x", boxX + 16)
    .attr("y", boxY + 32 + 16 + 2 + 10 + 2)
    .attr("class", "overline")
    .text(`closest to: ${d.closest}`);
  return true;
}

function mouseOut(d: vec, i: number): boolean {
  d3.select(this).attr("r", dotSize);
  d3.select("#box").remove();
  return true;
}
</script>

<style>
svg {
  height: 50vh;
}
</style>
