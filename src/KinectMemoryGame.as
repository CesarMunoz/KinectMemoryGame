package
{
	import away3d.bounds.*;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.core.pick.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.utils.*;
	
	import com.greensock.TweenLite;
	
	
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.Timer;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="60", quality="HIGH")]
	
	public class KinectMemoryGame extends Sprite
	{
		//textures
		[Embed(source='/textures/texture0.png')]
		private static const texture0:Class;
		[Embed(source='/textures/texture1.png')]
		private static const texture1:Class;
		[Embed(source='/textures/texture2.png')]
		private static const texture2:Class;
		[Embed(source='/textures/texture3.png')]
		private static const texture3:Class;
		[Embed(source='/textures/texture4.png')]
		private static const texture4:Class;
		[Embed(source='/textures/textureback.png')]
		private static const textureback:Class;
		[Embed(source='/textures/texturewoodSmall.png')]
		private static const texturewood:Class;
		
		// 3D view 
		private var scene:Scene3D;
		private var view:View3D;
		private var camera:Camera3D;
		private var cube:CubeGeometry;
		
		// objects
		private var totalchildren:int=10;
		private var cards:Array;
		private var cardwidth:Number = 110;
		private var cardheight:Number = 150;
		private var cardsholder:ObjectContainer3D;
		
		private var xoffset:Number = 10;
		private var yoffset:Number = 10;
		
		private var selectedCard1:Mesh;
		private var selectedCard2:Mesh;
		
		public function KinectMemoryGame()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new View3D();
			scene = view.scene;
			camera = view.camera;
			view.backgroundColor = 999999;
			addChild(view);
			//setup the camera
			view.camera.z = -600;
			view.camera.y = -300;
			view.camera.lookAt(new Vector3D());
			
			createGround();
			initCards();
			randomizeCards();
			addCardsToScene();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function createGround():void 
		{
			cube = new CubeGeometry(800, 500, 20);
			var cubeMesh:Mesh = new Mesh(cube, new TextureMaterial(Cast.bitmapTexture(texturewood)));
			var table:ObjectContainer3D = new ObjectContainer3D();
			table.addChild(cubeMesh);
			view.scene.addChild(table);
		}
		
		private function initCards():void
		{
			cards = new Array();
			var textures:Array = new Array();
			textures = [texture0, texture1, texture2, texture3, texture4];
			for(var i:int=0; i<textures.length; i++)
			{
				var card1:ObjectContainer3D = createCard(textures[i], i);
				var card2:ObjectContainer3D = createCard(textures[i], i);
				cards.push(card1);
				cards.push(card2);
			}
		}
		
		private function createCard(texture:Class,id:int):ObjectContainer3D
		{
			var card:ObjectContainer3D = new ObjectContainer3D();
			
			/*PlaneGeometry is not rendering properly - a flattened cube will do for now...
			
			var front:PlaneGeometry = new PlaneGeometry(cardwidth, cardheight);
			//var frontMesh:Mesh = new Mesh(front, new TextureMaterial(Cast.bitmapTexture(texture)));
			var frontMesh:Mesh = new Mesh(front);
			
			var back:PlaneGeometry = new PlaneGeometry(cardwidth, cardheight);
			//var backMesh:Mesh = new Mesh(back, new TextureMaterial(Cast.bitmapTexture(textureback)));
			var backMesh:Mesh = new Mesh(back);
			frontMesh.y = 180;
			backMesh.z = 180;
			backMesh.y = 180;
			
			card.addChild(frontMesh);
			card.addChild(backMesh);*/
			
			var front:CubeGeometry = new CubeGeometry(cardwidth, cardheight, 0);
			var frontMesh:Mesh = new Mesh(front, new TextureMaterial(Cast.bitmapTexture(texture)));
			card.addChild(frontMesh);
			
			var back:CubeGeometry = new CubeGeometry(cardwidth, cardheight, 0);
			var backMesh:Mesh = new Mesh(back, new TextureMaterial(Cast.bitmapTexture(textureback)));
			backMesh.z = -.1;
			backMesh.extra = {};
			backMesh.extra.id = id;
			backMesh.extra.targetCard = card;
			backMesh.mouseEnabled = true;
			backMesh.addEventListener(MouseEvent3D.CLICK, onBackClicked);
			
			card.addChild(backMesh);
			
			//card.rotationX = 180;
			
			return card;
		}
		
		private function addCardsToScene():void
		{
			cardsholder = new ObjectContainer3D();
			var currentindex:int = 0
			
			for(var i:int=0; i<2; i++) {
				for(var b:int=0; b<5; b++) {
					cards[currentindex].x = b*(cardwidth+xoffset)+cardwidth/2;
					cards[currentindex].y = i*(cardheight+yoffset)+cardheight/2;
					cardsholder.addChild(cards[currentindex]);
					currentindex++;
				}
			}
			
			var cardswidth:Number = (5*cardwidth) + (4*xoffset)
			var cardsheight:Number = (2*cardheight) + (1*yoffset)
			
			cardsholder.x =- cardswidth/2;
			cardsholder.z = -11;
			cardsholder.y =- cardsheight/2;
			
			view.scene.addChild(cardsholder)
		}
		
		private function randomizeCards():void{
			var newArray:Array = new Array();
			while(cards.length > 0){
				newArray.push(cards.splice(Math.floor(Math.random()*cards.length), 1)[0]);
			}
			cards = newArray;
		}
		
		private function onBackClicked(e:Event):void
		{
			//e.currentTarget.mouseEnabled = false;
			trace('onBackClicked: '+	e.currentTarget);
			trace('selectedCard1 :'+selectedCard1)
			//if(disableMouseEvents==false) { 
				if(selectedCard1==null) {
					trace('onBackClicked: 	1st Card');
					selectedCard1 = e.currentTarget as Mesh;
					//selectedCard1 = e.currentTarget; 
				}else { 
					if(selectedCard2==null) {
						trace('onBackClicked: 	2nd Card');
						selectedCard2 = e.currentTarget as Mesh;
						waitForDecision();
						//disableMouseEvents = true;
					}
				}
				TweenLite.to(e.currentTarget.extra.targetCard, .5, {z:-50, rotationY:180});
			//}
		}
		
		private function waitForDecision():void 
		{
			var timer:Timer = new Timer(1000,1);
			timer.addEventListener(TimerEvent.TIMER,makeDecision);
			timer.start();
		}
		
		private function makeDecision(e:Event):void 
		{
			trace('makeDecision   selectedCard1.extra.targetCard: '+selectedCard1.extra.targetCard)
			if(selectedCard1.extra.id == selectedCard2.extra.id) {
				// NO alpha property on ObjectContainer3D??
				//TweenLite.to(selectedCard1.extra.targetCard, .5, {alpha:0, onComplete:removeCard, onCompleteParams:[selectedCard1.extra.targetCard]});
				//TweenLite.to(selectedCard2.extra.targetCard, .5, {alpha:0, onComplete:removeCard, onCompleteParams:[selectedCard2.extra.targetCard]});
				removeCard(selectedCard1.extra.targetCard);
				removeCard(selectedCard2.extra.targetCard);
			}else { 
				TweenLite.to(selectedCard1.extra.targetCard, .5, {z:0, rotationY:0});
				TweenLite.to(selectedCard2.extra.targetCard, .5, {z:0, rotationY:0});
			}
			//disableMouseEvents = false
			selectedCard1 = null;
			selectedCard2 = null;
		}
		
		private function removeCard(e:ObjectContainer3D):void 
		{
			trace('removeCard : '+e);
			e.visible = false;
			cardsholder.removeChild(e)
			totalchildren--
			if(totalchildren==0) {
				trace("WIN")
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			// Render 3D.
			view.render();
		}
		
		private function onResize(e:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
		}
	}
}