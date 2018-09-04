<template>
  <div class="index">
     <div class="container">
          <ul class="steps-bar">
            <li class="active" v-for="i in length" :key="i"> </li>
          </ul>
      </div>
  </div>
</template>
<script>
export default {
  props:['length'],
  data () {
    return {
    }
  },
}
</script>

<style scoped>
.container{
     width: 35%;
    position: absolute;
    z-index: 1;
    margin-top: 20px;
}
.steps-bar{
  counter-reset: step;
}
.steps-bar li{
  float: left;
  width: 14.28%;
  position: relative;
  text-align: center;
}
.steps-bar li:before{
  content:counter(step);
  counter-increment: step;
  width: 30px;
  height: 30px;
  border: 2px solid #bebebe;
  display: block;
  margin: 0 auto 10px auto;
  border-radius: 50%;
  line-height: 27px;
  background: white;
  color: #bebebe;
  text-align: center;
  font-weight: bold;
}
.steps-bar li:after{
  content: '';
  position: absolute;
  width:100%;
  height: 3px;
  background: #979797;
  top: 15px;
  left: -50%;
  z-index: -1;
}
.steps-bar li.active:before{
 border-color: #3aac5d;
 background: #3aac5d;
 color: white
}
.steps-bar li.active:after{
 background: #3aac5d;
}
.steps-bar li.active - li:after{
 background: #3aac5d;
}
.steps-bar li.active - li:before{
border-color: #3aac5d;
background: #3aac5d;
color: white
}
.steps-bar li:first-child:after{
 content: none;
}
</style>
